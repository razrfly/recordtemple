# frozen_string_literal: true

# Calculates popularity scores for records based on configurable factors.
# Configuration is loaded from config/popularity.yml
#
# Usage:
#   RecordPopularityCalculator.calculate(record)  # => Integer (0-100)
#   RecordPopularityCalculator.recalculate_all!   # Updates all records
#   RecordPopularityCalculator.validate_config!   # Raises if config invalid
#
class RecordPopularityCalculator
  class ConfigurationError < StandardError; end

  class << self
    def config
      @config ||= Rails.application.config_for(:popularity).deep_symbolize_keys
    end

    def reload_config!
      @config = nil
      @catalog_counts = nil
      config
    end

    # Calculate popularity score for a single record
    def calculate(record)
      score = 0.0
      score += boolean_score(record)
      score += graduated_score(record)
      score += logarithmic_score(record)
      score += format_rarity_score(record)
      score.round.clamp(0, 100)
    end

    # Recalculate all records with progress reporting
    def recalculate_all!(dry_run: false, verbose: false)
      preload_catalog_counts!

      total = Record.count
      updated = 0
      score_distribution = Hash.new(0)

      Record.includes(:price, :record_format).find_each.with_index do |record, index|
        # Get attachment counts efficiently
        images_count = attachment_counts[:images][record.id] || 0
        songs_count = attachment_counts[:songs][record.id] || 0

        score = calculate_with_counts(record, images_count, songs_count)
        score_distribution[score / 10 * 10] += 1

        unless dry_run
          record.update_columns(
            popularity_score: score,
            images_count: images_count,
            songs_count: songs_count
          )
        end

        updated += 1

        if verbose && (index % 1000).zero?
          puts "Processed #{index + 1}/#{total} records..."
        end
      end

      if verbose
        puts "\nScore Distribution:"
        score_distribution.sort.each do |range, count|
          bar = "*" * (count / 100)
          puts "  #{range.to_s.rjust(3)}-#{(range + 9).to_s.rjust(3)}: #{count.to_s.rjust(5)} #{bar}"
        end
        puts "\nTotal: #{updated} records #{dry_run ? '(dry run)' : 'updated'}"
      end

      { total: updated, distribution: score_distribution, dry_run: dry_run }
    end

    # Validate configuration file
    def validate_config!
      errors = []

      # Check required sections exist
      %i[boolean_factors graduated_factors logarithmic_factors format_rarity].each do |section|
        errors << "Missing section: #{section}" unless config[section]
      end

      # Validate boolean factors
      config[:boolean_factors]&.each do |name, settings|
        errors << "#{name}: missing points" unless settings[:points]
        errors << "#{name}: points must be positive" if settings[:points]&.negative?
      end

      # Validate graduated factors
      config[:graduated_factors]&.each do |name, settings|
        errors << "#{name}: missing max_points" unless settings[:max_points]
      end

      # Validate logarithmic factors
      config[:logarithmic_factors]&.each do |name, settings|
        errors << "#{name}: missing multiplier" unless settings[:multiplier]
        errors << "#{name}: missing max_points" unless settings[:max_points]
      end

      # Calculate theoretical maximum
      max_score = theoretical_max_score
      if max_score > 120
        errors << "Theoretical max score (#{max_score}) exceeds 120 - consider reducing weights"
      end

      raise ConfigurationError, errors.join("; ") if errors.any?

      { valid: true, theoretical_max: max_score }
    end

    def theoretical_max_score
      max = 0

      config[:boolean_factors]&.each_value do |settings|
        max += settings[:points].to_i
      end

      config[:graduated_factors]&.each_value do |settings|
        max += settings[:max_points].to_i
      end

      config[:logarithmic_factors]&.each_value do |settings|
        max += settings[:max_points].to_i
      end

      max += config.dig(:format_rarity, :bonuses)&.values&.max.to_i

      max
    end

    private

    # Calculate with pre-fetched counts (for batch operations)
    def calculate_with_counts(record, images_count, songs_count)
      score = 0.0
      score += boolean_score_with_counts(record, images_count, songs_count)
      score += graduated_score_with_counts(record, images_count, songs_count)
      score += logarithmic_score(record)
      score += format_rarity_score(record)
      score.round.clamp(0, 100)
    end

    def boolean_score(record)
      boolean_score_with_counts(
        record,
        record.images_count.nonzero? || record.images.count,
        record.songs_count.nonzero? || record.songs.count
      )
    end

    def boolean_score_with_counts(record, images_count, songs_count)
      score = 0.0
      factors = config[:boolean_factors]

      score += factors.dig(:has_images, :points).to_f if images_count.positive?
      score += factors.dig(:has_songs, :points).to_f if songs_count.positive?
      score += factors.dig(:has_comment, :points).to_f if record.comment.present?
      score += factors.dig(:has_price_guide, :points).to_f if record.price_id.present?
      score += factors.dig(:has_identifier, :points).to_f if record.identifier_id.present?

      score
    end

    def graduated_score(record)
      graduated_score_with_counts(
        record,
        record.images_count.nonzero? || record.images.count,
        record.songs_count.nonzero? || record.songs.count
      )
    end

    def graduated_score_with_counts(record, images_count, songs_count)
      score = 0.0
      factors = config[:graduated_factors]

      # Images count bonus (after first)
      if images_count > 1
        img_settings = factors[:images_count_bonus]
        start_from = img_settings[:start_from] || 2
        bonus_count = [images_count - start_from + 1, 0].max
        score += [bonus_count * img_settings[:points_per_unit].to_f, img_settings[:max_points].to_f].min
      end

      # Songs count bonus (after first)
      if songs_count > 1
        song_settings = factors[:songs_count_bonus]
        start_from = song_settings[:start_from] || 2
        bonus_count = [songs_count - start_from + 1, 0].max
        score += [bonus_count * song_settings[:points_per_unit].to_f, song_settings[:max_points].to_f].min
      end

      # Comment length bonus
      if record.comment.present?
        comment_settings = factors[:comment_length_bonus]
        chars = record.comment.length
        bonus = (chars / 100.0) * comment_settings[:points_per_100_chars].to_f
        score += [bonus, comment_settings[:max_points].to_f].min
      end

      score
    end

    def logarithmic_score(record)
      score = 0.0
      factors = config[:logarithmic_factors]

      # Artist catalog depth
      artist_settings = factors[:artist_catalog_depth]
      artist_count = catalog_count(:artist, record.artist_id)
      score += [
        Math.log(artist_count + 1) * artist_settings[:multiplier].to_f,
        artist_settings[:max_points].to_f
      ].min

      # Label catalog depth
      label_settings = factors[:label_catalog_depth]
      label_count = catalog_count(:label, record.label_id)
      score += [
        Math.log(label_count + 1) * label_settings[:multiplier].to_f,
        label_settings[:max_points].to_f
      ].min

      # Price guide value
      if record.price&.price_high
        price_settings = factors[:price_guide_value]
        score += [
          Math.log(record.price.price_high + 1) * price_settings[:multiplier].to_f,
          price_settings[:max_points].to_f
        ].min
      end

      score
    end

    def format_rarity_score(record)
      return 0.0 unless record.record_format

      format_name = record.record_format.name
      bonuses = config.dig(:format_rarity, :bonuses) || {}
      default_points = config.dig(:format_rarity, :default_points) || 0

      bonuses[format_name.to_sym] || bonuses[format_name] || default_points
    end

    # Preload catalog counts for batch operations
    def preload_catalog_counts!
      @catalog_counts = {
        artist: Record.group(:artist_id).count,
        label: Record.group(:label_id).count
      }
    end

    def catalog_count(type, id)
      return 0 unless id

      if @catalog_counts&.dig(type)
        @catalog_counts[type][id] || 0
      else
        case type
        when :artist then Record.where(artist_id: id).count
        when :label then Record.where(label_id: id).count
        else 0
        end
      end
    end

    # Preload attachment counts for batch operations
    def attachment_counts
      @attachment_counts ||= {
        images: ActiveStorage::Attachment
          .where(record_type: "Record", name: "images")
          .group(:record_id)
          .count,
        songs: ActiveStorage::Attachment
          .where(record_type: "Record", name: "songs")
          .group(:record_id)
          .count
      }
    end
  end
end
