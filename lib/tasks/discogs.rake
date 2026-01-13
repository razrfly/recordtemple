# frozen_string_literal: true

namespace :discogs do
  desc "Match unmatched records to Discogs releases"
  task match: :environment do
    limit = ENV["LIMIT"]&.to_i
    user_id = ENV["USER_ID"]&.to_i
    dry_run = ENV["DRY_RUN"] == "true"
    high_confidence_only = ENV["HIGH_CONFIDENCE"] == "true"

    puts "=" * 60
    puts "Discogs Matching"
    puts "=" * 60
    puts ""
    puts "Options:"
    puts "  Limit: #{limit || 'all'}"
    puts "  User ID: #{user_id || 'all users'}"
    puts "  Dry run: #{dry_run}"
    puts "  High confidence only: #{high_confidence_only}"
    puts ""

    result = DiscogsMatchingJob.match_all!(
      limit: limit,
      user_id: user_id.presence,
      dry_run: dry_run,
      skip_low_confidence: high_confidence_only
    )

    puts ""
    puts "=" * 60
    puts "Results"
    puts "=" * 60
    puts "  Total processed: #{result[:total]}"
    puts "  Matched: #{result[:matched]}"
    puts "  Skipped (below threshold): #{result[:skipped]}"
    puts "  No match found: #{result[:no_match]}"
    puts "  Match rate: #{result[:match_rate]}%"
    puts ""
  end

  desc "Show Discogs matching statistics"
  task stats: :environment do
    puts "=" * 60
    puts "Discogs Matching Statistics"
    puts "=" * 60
    puts ""

    total_records = Record.count
    matched = Record.discogs_matched.count
    unmatched = Record.discogs_unmatched.count
    high_conf = Record.discogs_high_confidence.count
    low_conf = Record.discogs_low_confidence.count
    releases = DiscogsRelease.count

    puts "Records:"
    puts "  Total: #{total_records}"
    match_percent = total_records.positive? ? (matched.to_f / total_records * 100).round(1) : 0
    puts "  Matched: #{matched} (#{match_percent}%)"
    puts "  Unmatched: #{unmatched}"
    puts ""
    puts "Match Quality:"
    puts "  High confidence (85+): #{high_conf}"
    puts "  Low confidence (<85): #{low_conf}"
    puts ""
    puts "Discogs Releases: #{releases}"
    puts "  Avg records per release: #{releases.positive? ? (matched.to_f / releases).round(1) : 0}"
    puts ""

    # Method breakdown
    puts "Match Methods:"
    Record.discogs_matched.group(:discogs_match_method).count.each do |method, count|
      puts "  #{method}: #{count}"
    end
    puts ""

    # Confidence distribution
    puts "Confidence Distribution:"
    distribution = Record.discogs_matched.group(
      Arel.sql("CASE
        WHEN discogs_confidence >= 95 THEN 'Excellent (95+)'
        WHEN discogs_confidence >= 85 THEN 'High (85-94)'
        WHEN discogs_confidence >= 75 THEN 'Medium (75-84)'
        ELSE 'Low (<75)'
      END")
    ).count
    distribution.each do |range, count|
      puts "  #{range}: #{count}"
    end
    puts ""
  end

  desc "Enqueue unmatched records for background processing"
  task enqueue: :environment do
    limit = ENV["LIMIT"]&.to_i
    user_id = ENV["USER_ID"]&.to_i

    puts "Enqueueing records for background matching..."
    count = DiscogsMatchingJob.enqueue_all!(
      limit: limit,
      user_id: user_id.presence
    )
    puts "Enqueued #{count} records"
  end

  desc "Unlink all Discogs matches (use with caution)"
  task reset: :environment do
    unless ENV["CONFIRM"] == "yes"
      puts "This will unlink ALL Discogs matches."
      puts "Run with CONFIRM=yes to proceed."
      exit 1
    end

    puts "Unlinking all Discogs matches..."
    count = Record.discogs_matched.update_all(
      discogs_release_id: nil,
      discogs_confidence: nil,
      discogs_match_method: nil,
      discogs_matched_at: nil
    )
    puts "Unlinked #{count} records"

    puts "Removing orphaned DiscogsReleases..."
    orphaned = DiscogsRelease.left_joins(:records).where(records: { id: nil }).delete_all
    puts "Removed #{orphaned} orphaned releases"
  end

  desc "Show sample matches for review"
  task sample: :environment do
    count = (ENV["COUNT"] || 10).to_i
    confidence = ENV["CONFIDENCE"] || "low"

    puts "=" * 60
    puts "Sample #{confidence.capitalize} Confidence Matches"
    puts "=" * 60
    puts ""

    scope = case confidence
            when "high"
              Record.discogs_high_confidence
            when "low"
              Record.discogs_low_confidence
            else
              Record.discogs_matched
            end

    scope.includes(:discogs_release, :artist, :label).order(:discogs_confidence).limit(count).each do |record|
      release = record.discogs_release
      puts "Record ##{record.id}: #{record.artist&.name || record.cached_artist}"
      puts "  RecordTemple: #{record.cached_artist} - #{record.cached_label} (#{record.yearbegin})"
      puts "  Discogs: #{release.title}"
      puts "  Confidence: #{record.discogs_confidence}% (#{record.discogs_match_method})"
      puts "  URL: #{release.discogs_url}"
      puts ""
    end
  end

  desc "Show price validation status breakdown"
  task validation_status: :environment do
    puts "=" * 60
    puts "Discogs Price Validation Status"
    puts "=" * 60
    puts ""

    # Overall status breakdown
    statuses = Record.where.not(discogs_release_id: nil)
                     .group(:discogs_price_validation)
                     .count

    puts "Validation Status Breakdown:"
    statuses.each do |status, count|
      emoji = case status
              when "verified" then "✅"
              when "probable" then "👍"
              when "uncertain" then "⚠️"
              when "likely_wrong" then "❌"
              when "guide_undervalued" then "💰"
              else "❓"
              end
      puts "  #{emoji} #{status || 'unvalidated'}: #{count}"
    end
    puts ""

    # High-value breakdown for likely_wrong
    puts "High-Value 'likely_wrong' Records (needing fix):"
    high_value = Record.joins(:price)
                       .where(discogs_price_validation: "likely_wrong")
                       .where("(prices.price_low::numeric + prices.price_high::numeric) / 2.0 >= 100")
                       .count
    puts "  $100+ records: #{high_value}"
    puts ""
  end

  desc "Clear likely_wrong Discogs matches for re-matching"
  task clear_wrong: :environment do
    min_value = (ENV["MIN_VALUE"] || 0).to_i
    dry_run = ENV["DRY_RUN"] == "true"

    puts "=" * 60
    puts "Clear Likely Wrong Discogs Matches"
    puts "=" * 60
    puts ""
    puts "Options:"
    puts "  Min guide value: $#{min_value}"
    puts "  Dry run: #{dry_run}"
    puts ""

    scope = Record.where(discogs_price_validation: "likely_wrong")
    if min_value > 0
      scope = scope.joins(:price)
                   .where("(prices.price_low::numeric + prices.price_high::numeric) / 2.0 >= ?", min_value)
    end

    count = scope.count
    puts "Found #{count} 'likely_wrong' records to clear"

    if count.zero?
      puts "Nothing to do."
      exit 0
    end

    if dry_run
      puts ""
      puts "Sample records that would be cleared:"
      scope.includes(:price, :discogs_release).limit(10).each do |record|
        guide_mid = record.price ? (record.price.price_low.to_f + record.price.price_high.to_f) / 2 : 0
        puts "  ##{record.id}: #{record.cached_artist} - #{record.price&.detail}"
        puts "    Guide: $#{guide_mid.round(0)} → Discogs: $#{record.discogs_release&.lowest_price}"
        puts "    Matched to: #{record.discogs_release&.title}"
      end
      puts ""
      puts "Run without DRY_RUN=true to actually clear these matches."
    else
      unless ENV["CONFIRM"] == "yes"
        puts ""
        puts "This will clear #{count} Discogs matches."
        puts "Run with CONFIRM=yes to proceed."
        exit 1
      end

      puts "Clearing #{count} matches..."
      cleared = scope.update_all(
        discogs_release_id: nil,
        discogs_confidence: nil,
        discogs_match_method: nil,
        discogs_matched_at: nil,
        discogs_price_validation: nil
      )
      puts "Cleared #{cleared} records"
      puts ""
      puts "Run 'bin/rails discogs:match' to re-match these records."
    end
  end

  desc "Show comparison: Price Guide vs Discogs for validated matches"
  task compare_prices: :environment do
    puts "=" * 60
    puts "Price Guide vs Discogs Comparison (Verified Matches)"
    puts "=" * 60
    puts ""

    # Get verified and probable matches with prices
    records = Record.joins(:price, :discogs_release)
                    .where(discogs_price_validation: %w[verified probable])
                    .where.not("discogs_releases.lowest_price" => nil)
                    .select(
                      "records.id",
                      "records.cached_artist",
                      "prices.detail as price_detail",
                      "(prices.price_low + prices.price_high) / 2.0 as guide_mid",
                      "discogs_releases.lowest_price as discogs_price",
                      "discogs_releases.title as discogs_title"
                    )
                    .order("guide_mid DESC")
                    .limit(20)

    puts "Top 20 Verified Matches (sorted by guide value):"
    puts ""
    records.each do |r|
      if r.guide_mid.to_f.zero?
        puts "❓ #{r.cached_artist}: #{r.price_detail}"
        puts "   Guide: $0 → Discogs: $#{r.discogs_price} (N/A)"
        puts ""
        next
      end
      ratio = (r.discogs_price.to_f / r.guide_mid.to_f * 100).round(0)
      indicator = case ratio
                  when 80..120 then "✅"
                  when 50..80 then "⬇️"
                  when 120..150 then "⬆️"
                  else "❓"
                  end
      puts "#{indicator} #{r.cached_artist}: #{r.price_detail}"
      puts "   Guide: $#{r.guide_mid.round(0)} → Discogs: $#{r.discogs_price} (#{ratio}%)"
      puts ""
    end

    # Summary stats
    stats = Record.joins(:price, :discogs_release)
                  .where(discogs_price_validation: %w[verified probable])
                  .where.not("discogs_releases.lowest_price" => nil)

    total_guide = stats.sum("(prices.price_low + prices.price_high) / 2.0")
    total_discogs = stats.sum("discogs_releases.lowest_price")
    count = stats.count

    puts "=" * 60
    puts "Summary for #{count} Verified/Probable Matches:"
    puts "  Total Guide Value: $#{total_guide.round(0)}"
    puts "  Total Discogs Value: $#{total_discogs.round(0)}"
    ratio_display = total_guide.to_f.zero? ? "N/A" : "#{(total_discogs.to_f / total_guide * 100).round(1)}%"
    puts "  Ratio: #{ratio_display}"
    puts ""
  end
end
