# frozen_string_literal: true

module Admin
  class RecordsController < ApplicationController
    COLLECTION_USER_ID = 1

    before_action :require_admin
    before_action :set_record, only: [:edit, :update]

    VALUE_TIERS = [
      ["$1,000+", 1000, nil],
      ["$500–999", 500, 1000],
      ["$250–499", 250, 500],
      ["$100–249", 100, 250],
      ["$50–99", 50, 100],
      ["$25–49", 25, 50],
      ["$10–24", 10, 25],
      ["Under $10", 0, 10]
    ].freeze

    CONFIDENCE_LEVELS = %w[High Medium Low Suspect].freeze

    def index
      base = Record.where(user_id: COLLECTION_USER_ID)

      # Apply text search before valuation joins (pg_search needs clean scope)
      if params[:search].present?
        base = base.wide_search(params[:search])
      end

      records = base.with_valuation

      # Confidence filter
      if params[:confidence].present? && CONFIDENCE_LEVELS.include?(params[:confidence])
        records = records.where("(#{Record.confidence_sql}) = ?", params[:confidence])
      end

      # Value tier filter
      if params[:tier].present?
        tier = VALUE_TIERS.find { |label, _, _| label == params[:tier] }
        if tier
          _, floor, ceiling = tier
          records = records.where("(#{Record.best_value_sql}) >= ?", floor)
          records = records.where("(#{Record.best_value_sql}) < ?", ceiling) if ceiling
        end
      end

      # Value range (manual min/max)
      if params[:min_value].present?
        records = records.where("(#{Record.best_value_sql}) >= ?", params[:min_value].to_f)
      end
      if params[:max_value].present?
        records = records.where("(#{Record.best_value_sql}) <= ?", params[:max_value].to_f)
      end

      # Pricing status filters
      case params[:pricing]
      when "has_guide"
        records = records.where("prices.price_high > 0")
      when "has_personal"
        records = records.where("records.value > 0")
      when "has_discogs"
        records = records.where("discogs_releases.lowest_price IS NOT NULL")
      when "no_price"
        records = records.where("(prices.price_high IS NULL OR prices.price_high = 0) AND (records.value IS NULL OR records.value = 0)")
      end

      # Ransack filters for genre, format, condition
      if params[:genre_id].present?
        records = records.where(genre_id: params[:genre_id])
      end
      if params[:format_id].present?
        records = records.where(record_format_id: params[:format_id])
      end
      if params[:condition].present?
        records = records.where(condition: params[:condition])
      end

      # Sorting
      sort_col = params[:sort] || "best_value"
      direction = params[:direction] == "asc" ? "ASC" : "DESC"
      records = records.order(Arel.sql("#{sort_sql_for(sort_col)} #{direction} NULLS LAST"))

      respond_to do |format|
        format.html do
          @pagy, @records = pagy(records, limit: 50)
          @stats = compute_stats(base)
          load_filter_options
        end
        format.csv do
          send_csv_export(records)
        end
      end
    end

    def edit
      @record_with_valuation = Record.where(id: @record.id).with_valuation.first
      @conditions = Record.conditions.keys
    end

    def update
      if @record.update(admin_record_params)
        redirect_to admin_records_path, notice: "Record updated."
      else
        @record_with_valuation = Record.where(id: @record.id).with_valuation.first
        @conditions = Record.conditions.keys
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_record
      @record = Record.where(user_id: COLLECTION_USER_ID).find(params[:id])
    end

    def admin_record_params
      params.require(:record).permit(:value, :condition, :comment)
    end

    def require_admin
      unless current_user&.admin?
        redirect_to root_path, alert: "Admin access required"
      end
    end

    def compute_stats(base_scope)
      valuation_scope = base_scope.with_valuation

      total_count = base_scope.count
      total_value = base_scope
        .joins("LEFT JOIN prices ON prices.id = records.price_id")
        .pick(Arel.sql("COALESCE(SUM(#{Record.best_value_sql}), 0)"))
        .to_f

      # Confidence breakdown via GROUP BY on the SQL expression
      breakdown = valuation_scope
        .group(Arel.sql("(#{Record.confidence_sql})"))
        .pluck(Arel.sql("(#{Record.confidence_sql})"), Arel.sql("COUNT(*)"), Arel.sql("COALESCE(SUM(#{Record.best_value_sql}), 0)"))

      confidence_stats = {}
      breakdown.each do |level, count, value|
        confidence_stats[level] = { count: count, value: value.to_f }
      end

      {
        total_count: total_count,
        total_value: total_value,
        confidence: confidence_stats
      }
    end

    def load_filter_options
      base = Record.where(user_id: COLLECTION_USER_ID)

      @genres = Genre.joins(:records)
                     .where(records: { user_id: COLLECTION_USER_ID })
                     .group("genres.id", "genres.name")
                     .order(Arel.sql("COUNT(records.id) DESC"))
                     .limit(30)
                     .pluck(Arel.sql("genres.id"), Arel.sql("genres.name"), Arel.sql("COUNT(records.id)"))
                     .map { |id, name, count| { id: id, name: name, count: count } }

      @formats = RecordFormat.joins(:records)
                              .where(records: { user_id: COLLECTION_USER_ID })
                              .group("record_formats.id", "record_formats.name")
                              .order(Arel.sql("COUNT(records.id) DESC"))
                              .pluck(Arel.sql("record_formats.id"), Arel.sql("record_formats.name"), Arel.sql("COUNT(records.id)"))
                              .map { |id, name, count| { id: id, name: name, count: count } }

      @conditions = base.group(:condition)
                        .count
                        .sort_by { |_, count| -count }
                        .map { |condition, count| { value: condition, count: count } }
    end

    def sort_sql_for(column)
      case column
      when "best_value"    then Record.best_value_sql
      when "adjusted_value" then Record.adjusted_value_sql
      when "personal_value" then "COALESCE(records.value, 0)"
      when "guide_value"   then "COALESCE(prices.price_high, 0)"
      when "discogs_value" then "COALESCE(discogs_releases.lowest_price, 0)"
      when "artist"        then "LOWER(artists.name)"
      when "label"         then "LOWER(labels.name)"
      when "condition"     then "records.condition"
      when "confidence"    then "(#{Record.confidence_sql})"
      else Record.best_value_sql
      end
    end

    def send_csv_export(records)
      require "csv"

      rows = records.limit(10_000).to_a

      csv_data = CSV.generate do |csv|
        csv << [
          "Rank", "Record ID", "Artist", "Label", "Genre", "Format",
          "Detail", "Condition", "Price Low", "Price High",
          "Personal Value", "Adjusted Value", "Best Value",
          "Discogs Lowest Price",
          "Confidence", "Guide/Personal Ratio",
          "Comment", "Footnote"
        ]

        rows.each_with_index do |r, i|
          confidence = Record.compute_confidence(r)
          guide_adj = r[:adjusted_value].to_f
          personal = r[:personal_value].to_f
          has_guide = r[:price_high].to_i > 0
          has_personal = personal > 0
          ratio = (has_guide && has_personal && personal > 0) ? guide_adj / personal : nil
          ratio_str = ratio ? "#{ratio.round(1)}x" : ""

          csv << [
            i + 1,
            r.id,
            r[:artist_name],
            r[:label_name],
            r[:genre_name],
            r[:format_name],
            r[:price_detail],
            r.condition&.titleize || "N/A",
            r[:price_low],
            r[:price_high],
            r[:personal_value],
            r[:adjusted_value].to_f.round(0),
            r[:best_value].to_f.round(0),
            r[:discogs_lowest_price],
            confidence,
            ratio_str,
            r.comment,
            r[:price_footnote]
          ]
        end
      end

      send_data csv_data,
        filename: "value_explorer_#{Date.current}.csv",
        type: "text/csv",
        disposition: "attachment"
    end
  end
end
