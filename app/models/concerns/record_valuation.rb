# frozen_string_literal: true

module RecordValuation
  extend ActiveSupport::Concern

  AGREE_MIN           = 0.5
  AGREE_MAX           = 2.0
  WEAK_AGREE_MIN      = 0.2
  SOME_DISAGREE_MAX   = 5.0
  SIGNIFICANT_GAP_MAX = 10.0
  SUSPECT_MIN         = 0.1   # ratio below this → Suspect (wildly different)
  DISCOGS_CORR_MIN    = 1.0 / 3.0
  DISCOGS_CORR_MAX    = 3.0

  def self.discogs_corresponds?(discogs, guide, personal)
    return false unless discogs > 0
    (guide > 0 && (discogs / guide).between?(DISCOGS_CORR_MIN, DISCOGS_CORR_MAX)) ||
      (personal > 0 && (discogs / personal).between?(DISCOGS_CORR_MIN, DISCOGS_CORR_MAX))
  end

  class_methods do
    # Condition multipliers against price_high (Goldmine scale)
    # condition enum: mint=1, near_mint=2, vg++=3, vg+=4, very_good=5, good=6, poor=7
    def condition_multiplier_sql
      <<~SQL.squish
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
    end

    def adjusted_value_sql
      "COALESCE(#{condition_multiplier_sql}, records.value, 0)"
    end

    def best_value_sql
      "GREATEST(#{adjusted_value_sql}, COALESCE(records.value, 0), COALESCE(discogs_releases.lowest_price, 0))"
    end

    # SQL CASE expression for confidence — enables WHERE filtering and GROUP BY.
    # Threshold literals below mirror the Ruby constants above; keep in sync:
    #   AGREE_MIN=0.5, AGREE_MAX=2.0, WEAK_AGREE_MIN=0.2, SOME_DISAGREE_MAX=5.0,
    #   SIGNIFICANT_GAP_MAX=10.0, SUSPECT_MIN=0.1,
    #   DISCOGS_CORR_MIN≈0.333, DISCOGS_CORR_MAX=3.0
    def confidence_sql
      guide_adj = adjusted_value_sql
      <<~SQL.squish
        CASE
          WHEN prices.price_high > 0 AND records.value > 0 THEN
            CASE
              WHEN (#{guide_adj}) / records.value >= 0.5 AND (#{guide_adj}) / records.value <= 2.0 THEN 'High'
              WHEN discogs_releases.lowest_price IS NOT NULL AND (
                (prices.price_high > 0 AND (#{guide_adj}) > 0 AND discogs_releases.lowest_price / (#{guide_adj}) BETWEEN 0.333 AND 3.0)
                OR (records.value > 0 AND discogs_releases.lowest_price / records.value BETWEEN 0.333 AND 3.0)
              ) THEN 'High'
              WHEN (#{guide_adj}) / records.value >= 0.2 AND (#{guide_adj}) / records.value <= 5.0 THEN 'Medium'
              WHEN (#{guide_adj}) / records.value > 5.0 AND (#{guide_adj}) / records.value <= 10.0 THEN 'Low'
              WHEN (#{guide_adj}) / records.value > 10.0 THEN 'Suspect'
              WHEN (#{guide_adj}) / records.value < 0.1 THEN 'Suspect'
              ELSE 'Low'
            END
          WHEN prices.price_high > 0 AND (records.value IS NULL OR records.value = 0) THEN
            CASE
              WHEN discogs_releases.lowest_price IS NOT NULL AND (#{guide_adj}) > 0 AND discogs_releases.lowest_price / (#{guide_adj}) BETWEEN 0.333 AND 3.0 THEN 'High'
              ELSE 'Medium'
            END
          WHEN (prices.price_high IS NULL OR prices.price_high = 0) AND records.value > 0 THEN 'Medium'
          ELSE 'Low'
        END
      SQL
    end

    # Pure Ruby confidence scoring — matches the SQL logic for CSV export and rake task
    def compute_confidence(row)
      guide_adj = row[:adjusted_value].to_f
      personal  = row[:personal_value].to_f
      discogs   = row[:discogs_lowest_price].to_f
      has_guide    = row[:price_high].to_i > 0
      has_personal = personal > 0

      ratio = (has_guide && has_personal && personal > 0) ? guide_adj / personal : nil
      discogs_corroborates = RecordValuation.discogs_corresponds?(discogs, guide_adj, personal)

      if ratio
        if ratio >= AGREE_MIN && ratio <= AGREE_MAX
          "High"
        elsif discogs_corroborates
          "High"
        elsif ratio >= WEAK_AGREE_MIN && ratio <= SOME_DISAGREE_MAX
          "Medium"
        elsif ratio > SOME_DISAGREE_MAX && ratio <= SIGNIFICANT_GAP_MAX
          "Low"
        elsif ratio > SIGNIFICANT_GAP_MAX
          "Suspect"
        elsif ratio < SUSPECT_MIN
          "Suspect"
        else # ratio SUSPECT_MIN–WEAK_AGREE_MIN (0.1–0.2)
          "Low"
        end
      elsif has_guide && !has_personal
        discogs_corroborates ? "High" : "Medium"
      elsif !has_guide && has_personal
        "Medium"
      else
        "Low"
      end
    end

    # Scope that adds computed valuation columns and all required JOINs
    def with_valuation
      select(
        "records.*",
        "artists.name AS artist_name",
        "labels.name AS label_name",
        "genres.name AS genre_name",
        "record_formats.name AS format_name",
        "prices.detail AS price_detail",
        "prices.price_low",
        "prices.price_high",
        "records.value AS personal_value",
        "#{adjusted_value_sql} AS adjusted_value",
        "#{best_value_sql} AS best_value",
        "discogs_releases.lowest_price AS discogs_lowest_price",
        "prices.footnote AS price_footnote",
        "(#{confidence_sql}) AS confidence_level",
        "(#{self::HAS_IMAGES_SQL}) AS has_images",
        "(#{self::HAS_SONGS_SQL}) AS has_songs"
      )
      .joins("LEFT JOIN prices ON prices.id = records.price_id")
      .joins("LEFT JOIN artists ON artists.id = records.artist_id")
      .joins("LEFT JOIN labels ON labels.id = records.label_id")
      .joins("LEFT JOIN genres ON genres.id = records.genre_id")
      .joins("LEFT JOIN record_formats ON record_formats.id = records.record_format_id")
      .joins("LEFT JOIN discogs_releases ON discogs_releases.id = records.discogs_release_id")
    end
  end
end
