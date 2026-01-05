# frozen_string_literal: true

namespace :records do
  desc "Recalculate popularity scores for all records"
  task recalculate_popularity: :environment do
    dry_run = ENV["DRY_RUN"].present?
    verbose = ENV["VERBOSE"].present? || dry_run

    puts "=" * 60
    puts "Recalculating Popularity Scores"
    puts "=" * 60
    puts "Mode: #{dry_run ? 'DRY RUN (no changes will be saved)' : 'LIVE'}"
    puts "Records to process: #{Record.count}"
    puts "=" * 60
    puts

    start_time = Time.current

    result = RecordPopularityCalculator.recalculate_all!(
      dry_run: dry_run,
      verbose: verbose
    )

    elapsed = Time.current - start_time

    puts
    puts "=" * 60
    puts "Complete!"
    puts "  Records processed: #{result[:total]}"
    puts "  Time elapsed: #{elapsed.round(2)} seconds"
    puts "  Rate: #{(result[:total] / elapsed).round(0)} records/second"
    puts "=" * 60

    if dry_run
      puts
      puts "This was a DRY RUN. To apply changes, run:"
      puts "  rake records:recalculate_popularity"
    end
  end

  desc "Validate popularity scoring configuration"
  task validate_popularity_config: :environment do
    puts "Validating config/popularity.yml..."
    puts

    begin
      result = RecordPopularityCalculator.validate_config!
      config = RecordPopularityCalculator.config

      puts "Configuration is VALID"
      puts
      puts "Summary:"
      puts "  Version: #{config[:version]}"
      puts "  Theoretical max score: #{result[:theoretical_max]}"
      puts

      puts "Boolean Factors:"
      config[:boolean_factors]&.each do |name, settings|
        puts "  #{name}: #{settings[:points]} pts"
      end
      puts

      puts "Graduated Factors:"
      config[:graduated_factors]&.each do |name, settings|
        puts "  #{name}: up to #{settings[:max_points]} pts"
      end
      puts

      puts "Logarithmic Factors:"
      config[:logarithmic_factors]&.each do |name, settings|
        puts "  #{name}: multiplier=#{settings[:multiplier]}, max=#{settings[:max_points]} pts"
      end
      puts

      puts "Format Rarity Bonuses:"
      bonuses = config.dig(:format_rarity, :bonuses) || {}
      bonuses.sort_by { |_, v| -v }.first(10).each do |format, points|
        puts "  #{format}: +#{points} pts"
      end
      puts "  (#{bonuses.size} total formats configured)"

    rescue RecordPopularityCalculator::ConfigurationError => e
      puts "Configuration is INVALID!"
      puts
      puts "Errors:"
      e.message.split("; ").each do |error|
        puts "  - #{error}"
      end
      exit 1
    end
  end

  desc "Show popularity score statistics"
  task popularity_stats: :environment do
    puts "=" * 60
    puts "Popularity Score Statistics"
    puts "=" * 60
    puts

    total = Record.count
    scored = Record.where.not(popularity_score: 0).count
    unscored = total - scored

    puts "Overview:"
    puts "  Total records: #{total}"
    puts "  Scored (>0): #{scored} (#{(scored.to_f / total * 100).round(1)}%)"
    puts "  Unscored (0): #{unscored} (#{(unscored.to_f / total * 100).round(1)}%)"
    puts

    # Score statistics - using PostgreSQL-specific functions with fallback
    begin
      stats = Record.pluck(
        Arel.sql("MIN(popularity_score)"),
        Arel.sql("MAX(popularity_score)"),
        Arel.sql("AVG(popularity_score)"),
        Arel.sql("PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY popularity_score)")
      ).first
      median = stats[3]&.round(1)
    rescue ActiveRecord::StatementInvalid
      # Fallback for non-PostgreSQL databases
      stats = Record.pluck(
        Arel.sql("MIN(popularity_score)"),
        Arel.sql("MAX(popularity_score)"),
        Arel.sql("AVG(popularity_score)")
      ).first
      # Calculate median using database OFFSET/LIMIT to avoid loading all records
      count = Record.count
      if count.positive?
        mid = count / 2
        if count.even?
          # Average the two middle values for even-length arrays
          mid_values = Record.order(:popularity_score).offset(mid - 1).limit(2).pluck(:popularity_score)
          median = (mid_values.sum / 2.0).round(1)
        else
          median = Record.order(:popularity_score).offset(mid).limit(1).pick(:popularity_score)
        end
      else
        median = nil
      end
    end

    puts "Score Distribution:"
    puts "  Min: #{stats[0]}"
    puts "  Max: #{stats[1]}"
    puts "  Average: #{stats[2]&.round(1)}"
    puts "  Median: #{median}"
    puts

    # Distribution by decile
    puts "Score Ranges:"
    distribution = Record.group(
      Arel.sql("FLOOR(popularity_score / 10) * 10")
    ).count.sort

    max_count = distribution.map(&:last).max
    distribution.each do |range, count|
      range_start = range.to_i
      range_end = range_start + 9
      percentage = (count.to_f / total * 100).round(1)
      bar_length = (count.to_f / max_count * 40).round
      bar = "#" * bar_length

      puts "  #{range_start.to_s.rjust(3)}-#{range_end.to_s.rjust(3)}: #{count.to_s.rjust(6)} (#{percentage.to_s.rjust(5)}%) #{bar}"
    end
    puts

    # Top scored records
    puts "Top 10 Records by Popularity:"
    Record.includes(:artist, :label, :record_format)
          .order(popularity_score: :desc)
          .limit(10)
          .each_with_index do |record, i|
      puts "  #{(i + 1).to_s.rjust(2)}. Score #{record.popularity_score}: #{record.artist&.name} - #{record.label&.name} (#{record.record_format&.name})"
    end
    puts

    # Media correlation
    puts "Media Correlation:"
    with_images = Record.where("images_count > 0").count
    with_songs = Record.where("songs_count > 0").count
    with_both = Record.where("images_count > 0 AND songs_count > 0").count

    puts "  Records with images: #{with_images} (#{(with_images.to_f / total * 100).round(1)}%)"
    puts "  Records with songs: #{with_songs} (#{(with_songs.to_f / total * 100).round(1)}%)"
    puts "  Records with both: #{with_both} (#{(with_both.to_f / total * 100).round(1)}%)"

    # Average scores by media presence
    puts
    puts "Average Scores by Media:"
    avg_no_media = Record.where(images_count: 0, songs_count: 0).average(:popularity_score)&.round(1) || 0
    avg_images_only = Record.where("images_count > 0 AND songs_count = 0").average(:popularity_score)&.round(1) || 0
    avg_songs_only = Record.where("images_count = 0 AND songs_count > 0").average(:popularity_score)&.round(1) || 0
    avg_both = Record.where("images_count > 0 AND songs_count > 0").average(:popularity_score)&.round(1) || 0

    puts "  No media: #{avg_no_media}"
    puts "  Images only: #{avg_images_only}"
    puts "  Songs only: #{avg_songs_only}"
    puts "  Both: #{avg_both}"
  end

  desc "Reload popularity config (useful in development)"
  task reload_popularity_config: :environment do
    RecordPopularityCalculator.reload_config!
    puts "Popularity config reloaded from config/popularity.yml"
    Rake::Task["records:validate_popularity_config"].invoke
  end
end
