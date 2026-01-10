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
    puts "  Matched: #{matched} (#{(matched.to_f / total_records * 100).round(1)}%)"
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
end
