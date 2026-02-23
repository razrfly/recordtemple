# frozen_string_literal: true

namespace :records do
  desc "Export top N most valuable records as CSV (condition-adjusted). Usage: rake records:top[1000]"
  task :top, [:limit] => :environment do |_t, args|
    limit = (args[:limit] || ENV.fetch("LIMIT", 1000)).to_i
    output_path = ENV.fetch("OUTPUT", "tmp/top_#{limit}_records.csv")

    puts "=" * 70
    puts "Top #{limit} Most Valuable Records (Condition-Adjusted)"
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

    # Adjusted value: use condition-adjusted price_high, fall back to record.value
    adjusted_value_sql = "COALESCE(#{condition_sql}, records.value, 0)"

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
        "discogs_releases.lowest_price AS discogs_lowest_price"
      )
      .joins("LEFT JOIN prices ON prices.id = records.price_id")
      .joins("LEFT JOIN artists ON artists.id = records.artist_id")
      .joins("LEFT JOIN labels ON labels.id = records.label_id")
      .joins("LEFT JOIN genres ON genres.id = records.genre_id")
      .joins("LEFT JOIN record_formats ON record_formats.id = records.record_format_id")
      .joins("LEFT JOIN discogs_releases ON discogs_releases.id = records.discogs_release_id")
      .order(Arel.sql("#{adjusted_value_sql} DESC"))
      .limit(limit)

    # Collection-wide stats
    total_records = Record.where(user_id: user_id).count
    total_value_result = Record
      .where(user_id: user_id)
      .joins("LEFT JOIN prices ON prices.id = records.price_id")
      .pick(Arel.sql("SUM(#{adjusted_value_sql})"))
    total_value = total_value_result.to_f

    top_records = records.to_a
    top_value = top_records.sum { |r| r[:adjusted_value].to_f }

    puts "Collection: #{total_records} records, $#{total_value.round(0).to_fs(:delimited)} total adjusted value"
    puts "Top #{top_records.size}: $#{top_value.round(0).to_fs(:delimited)} (#{(top_value / total_value * 100).round(1)}% of total)"
    puts

    # Print top 25 to console
    preview_count = [25, top_records.size].min
    puts "Top #{preview_count} Preview:"
    puts "-" * 70
    puts format("%-4s %-30s %-20s %-10s %10s", "#", "Artist", "Label", "Condition", "Value")
    puts "-" * 70

    top_records.first(preview_count).each_with_index do |r, i|
      condition_name = r[:condition]&.to_s&.titleize || "N/A"
      value_str = "$#{r[:adjusted_value].to_f.round(0).to_fs(:delimited)}"
      puts format(
        "%-4s %-30s %-20s %-10s %10s",
        "#{i + 1}.",
        r[:artist_name].to_s.truncate(29),
        r[:label_name].to_s.truncate(19),
        condition_name.truncate(9),
        value_str
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
        "Personal Value", "Adjusted Value",
        "Discogs Lowest Price"
      ]

      top_records.each_with_index do |r, i|
        condition_name = r[:condition]&.to_s&.titleize || "N/A"
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
          r[:discogs_lowest_price]
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
    puts "-" * 50
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
      tier_records = top_records.select do |r|
        v = r[:adjusted_value].to_f
        v >= floor && v < ceiling
      end
      tier_value = tier_records.sum { |r| r[:adjusted_value].to_f }
      next if tier_records.empty?

      puts format(
        "  %-12s %6d records   $%s",
        label,
        tier_records.size,
        tier_value.round(0).to_fs(:delimited)
      )
    end
  end
end
