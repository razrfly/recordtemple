# frozen_string_literal: true

namespace :records do
  desc "Export top N most valuable records as CSV with confidence scoring. Usage: rake records:top[2000]"
  task :top, [:limit] => :environment do |_t, args|
    limit = (args[:limit] || ENV.fetch("LIMIT", 2000)).to_i
    output_path = ENV.fetch("OUTPUT", "tmp/top_#{limit}_records.csv")

    puts "=" * 70
    puts "Top #{limit} Most Valuable Records (Condition-Adjusted + Confidence)"
    puts "=" * 70
    puts

    # Condition multipliers against price_high (Goldmine scale)
    # condition enum: mint=1, near_mint=2, vg++=3, vg+=4, very_good=5, good=6, poor=7
    condition_sql = <<~SQL.squish
      CASE records.condition
        WHEN 1 THEN prices.price_high * 1.00
        WHEN 2 THEN prices.price_high * 0.95
        WHEN 3 THEN prices.price_high * 0.85
        WHEN 4 THEN prices.price_high * 0.75
        WHEN 5 THEN prices.price_high * 0.60
        WHEN 6 THEN prices.price_high * 0.40
        WHEN 7 THEN prices.price_high * 0.20
        ELSE prices.price_high * 0.60
      END
    SQL

    adjusted_value_sql = "COALESCE(#{condition_sql}, records.value, 0)"

    # Sort by the highest value from any source so we don't miss records
    # that rank high by personal value but low by price guide (or vice versa)
    best_value_sql = "GREATEST(#{adjusted_value_sql}, COALESCE(records.value, 0))"

    user_id = ENV.fetch("USER_ID", 1).to_i

    records = Record
      .where(user_id: user_id)
      .select(
        "records.id",
        "artists.name AS artist_name",
        "labels.name AS label_name",
        "genres.name AS genre_name",
        "record_formats.name AS format_name",
        "prices.detail AS price_detail",
        "records.condition",
        "prices.price_low",
        "prices.price_high",
        "records.value AS personal_value",
        "#{adjusted_value_sql} AS adjusted_value",
        "#{best_value_sql} AS best_value",
        "discogs_releases.lowest_price AS discogs_lowest_price",
        "records.comment",
        "prices.footnote AS price_footnote"
      )
      .joins("LEFT JOIN prices ON prices.id = records.price_id")
      .joins("LEFT JOIN artists ON artists.id = records.artist_id")
      .joins("LEFT JOIN labels ON labels.id = records.label_id")
      .joins("LEFT JOIN genres ON genres.id = records.genre_id")
      .joins("LEFT JOIN record_formats ON record_formats.id = records.record_format_id")
      .joins("LEFT JOIN discogs_releases ON discogs_releases.id = records.discogs_release_id")
      .order(Arel.sql("#{best_value_sql} DESC"))
      .limit(limit)

    # Collection-wide stats
    total_records = Record.where(user_id: user_id).count
    total_value_result = Record
      .where(user_id: user_id)
      .joins("LEFT JOIN prices ON prices.id = records.price_id")
      .pick(Arel.sql("SUM(#{adjusted_value_sql})"))
    total_value = total_value_result.to_f

    top_records = records.to_a

    # --- Confidence scoring ---
    # Compare price guide adjusted value against personal value and Discogs price.
    # Confidence levels:
    #   High   — guide and personal value agree within 2x, OR confirmed by Discogs
    #   Medium — only one price source, or guide/personal within 5x
    #   Low    — guide and personal diverge 5x-10x
    #   Suspect — guide and personal diverge >10x
    scored = top_records.map do |r|
      guide_adj = r[:adjusted_value].to_f
      personal = r[:personal_value].to_f
      discogs = r[:discogs_lowest_price].to_f
      has_guide = r[:price_high].to_i > 0
      has_personal = personal > 0
      has_discogs = discogs > 0

      # Ratio of guide adjusted to personal value
      ratio = (has_guide && has_personal && personal > 0) ? guide_adj / personal : nil

      # Check if Discogs corroborates (within 3x of either source)
      discogs_corroborates = if has_discogs
        (has_guide && guide_adj > 0 && discogs / guide_adj.clamp(1, Float::INFINITY) >= 0.15) ||
        (has_personal && personal > 0 && discogs / personal.clamp(1, Float::INFINITY) >= 0.15)
      else
        false
      end

      confidence = if ratio
        if ratio >= 0.5 && ratio <= 2.0
          "High"
        elsif discogs_corroborates
          "High"
        elsif ratio >= 0.2 && ratio <= 5.0
          "Medium"
        elsif ratio > 5.0 && ratio <= 10.0
          "Low"
        elsif ratio > 10.0
          "Suspect"
        else # ratio < 0.2
          "Low"
        end
      elsif has_guide && !has_personal
        has_discogs && discogs_corroborates ? "Medium" : "Medium"
      elsif !has_guide && has_personal
        "Medium"
      else
        "Low"
      end

      { record: r, confidence: confidence, ratio: ratio }
    end

    top_best_value = scored.sum { |s| s[:record][:best_value].to_f }

    # Console summary
    puts "Collection: #{total_records} records, $#{total_value.round(0).to_fs(:delimited)} total adjusted value"
    puts "Top #{scored.size}: $#{top_best_value.round(0).to_fs(:delimited)} best value"
    puts

    # Confidence breakdown
    puts "Confidence Breakdown:"
    puts "-" * 60
    %w[High Medium Low Suspect].each do |level|
      group = scored.select { |s| s[:confidence] == level }
      group_value = group.sum { |s| s[:record][:best_value].to_f }
      next if group.empty?
      puts format("  %-10s %5d records   $%s (%s%%)",
        level,
        group.size,
        group_value.round(0).to_fs(:delimited),
        (group_value / top_best_value * 100).round(1)
      )
    end
    puts

    # Print top 25 to console
    preview_count = [25, scored.size].min
    puts "Top #{preview_count} Preview:"
    puts "-" * 85
    puts format("%-4s %-26s %-16s %-8s %9s %9s %9s", "#", "Artist", "Label", "Confid.", "Best $", "Guide $", "My $")
    puts "-" * 90

    scored.first(preview_count).each_with_index do |s, i|
      r = s[:record]
      best_str = "$#{r[:best_value].to_f.round(0).to_fs(:delimited)}"
      guide_str = r[:price_high].to_i > 0 ? "$#{r[:adjusted_value].to_f.round(0).to_fs(:delimited)}" : "-"
      personal_str = r[:personal_value].to_i > 0 ? "$#{r[:personal_value].to_i.to_fs(:delimited)}" : "-"
      puts format(
        "%-4s %-26s %-16s %-8s %9s %9s %9s",
        "#{i + 1}.",
        r[:artist_name].to_s.truncate(25),
        r[:label_name].to_s.truncate(15),
        s[:confidence],
        best_str,
        guide_str,
        personal_str
      )
    end
    puts

    # Write CSV
    require "csv"
    dir = File.dirname(output_path)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)

    CSV.open(output_path, "w") do |csv|
      csv << [
        "Rank", "Record ID", "Artist", "Label", "Genre", "Format",
        "Detail", "Condition", "Price Low", "Price High",
        "Personal Value", "Adjusted Value", "Best Value",
        "Discogs Lowest Price",
        "Confidence", "Guide/Personal Ratio",
        "Location", "Comment", "Footnote"
      ]

      scored.each_with_index do |s, i|
        r = s[:record]
        condition_name = r[:condition]&.to_s&.titleize || "N/A"
        comment = r[:comment].to_s
        location = comment[/\[([^\]]+)\]\s*\z/, 1]
        ratio_str = s[:ratio] ? "#{s[:ratio].round(1)}x" : ""
        csv << [
          i + 1,
          r[:id],
          r[:artist_name],
          r[:label_name],
          r[:genre_name],
          r[:format_name],
          r[:price_detail],
          condition_name,
          r[:price_low],
          r[:price_high],
          r[:personal_value],
          r[:adjusted_value].to_f.round(0),
          r[:best_value].to_f.round(0),
          r[:discogs_lowest_price],
          s[:confidence],
          ratio_str,
          location,
          comment,
          r[:price_footnote]
        ]
      end
    end

    puts "CSV exported to: #{output_path}"
    puts
    puts "Options:"
    puts "  rake records:top[500]              # Different limit"
    puts "  OUTPUT=path.csv rake records:top    # Custom output path"

    # Value tier summary
    puts
    puts "Value Tier Breakdown:"
    puts "-" * 60
    tiers = [
      ["$1,000+", 1000],
      ["$500-$999", 500],
      ["$250-$499", 250],
      ["$100-$249", 100],
      ["$50-$99", 50],
      ["$25-$49", 25],
      ["$10-$24", 10],
      ["Under $10", 0]
    ]

    tiers.each_with_index do |(label, floor), idx|
      ceiling = idx > 0 ? tiers[idx - 1][1] : Float::INFINITY
      tier_scored = scored.select do |s|
        v = s[:record][:best_value].to_f
        v >= floor && v < ceiling
      end
      tier_value = tier_scored.sum { |s| s[:record][:best_value].to_f }
      high_conf = tier_scored.count { |s| s[:confidence] == "High" }
      next if tier_scored.empty?

      puts format(
        "  %-12s %6d records   $%s   (High confidence: %d)",
        label,
        tier_scored.size,
        tier_value.round(0).to_fs(:delimited),
        high_conf
      )
    end
  end
end
