# frozen_string_literal: true

module Admin
  class RecordsController < BaseController
    COLLECTION_USER_ID = 1
    before_action :set_record, only: [:show, :edit, :update, :destroy, :add_images, :add_songs, :destroy_attachment, :preview]

    CONFIDENCE_LEVELS = %w[High Medium Low Suspect].freeze

    def index
      base = Record.where(user_id: COLLECTION_USER_ID)

      # Apply text search via subquery to avoid pg_search rank column
      # conflicting with with_valuation's explicit SELECT list
      if params[:search].present?
        search_ids = base.wide_search(params[:search]).reselect(:id)
        base = base.where(id: search_ids)
      end

      records = base.with_valuation

      # Confidence filter
      if params[:confidence].present? && CONFIDENCE_LEVELS.include?(params[:confidence])
        records = records.where("(#{Record.confidence_sql}) = ?", params[:confidence])
      end

      # Price source (controls default sort + Min $ semantics)
      price_source = %w[guide my discogs].include?(params[:price_source]) ? params[:price_source] : "best"

      # Min value filter (source-aware)
      if params[:min_value].present?
        floor = params[:min_value].to_f
        records = case price_source
          when "guide"   then records.where("prices.price_high > 0 AND (#{Record.adjusted_value_sql}) >= ?", floor)
          when "my"      then records.where("records.value >= ?", floor)
          when "discogs" then records.where("discogs_releases.lowest_price >= ?", floor)
          else                records.where("(#{Record.best_value_sql}) >= ?", floor)
        end
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
      if params[:format_category].present?
        cat = params[:format_category]
        records = records.where(
          "record_formats.name = ? OR record_formats.name LIKE ?",
          cat, "#{ActiveRecord::Base.sanitize_sql_like(cat)}:%"
        )
      end
      if params[:condition].present?
        records = records.where(condition: params[:condition])
      end

      # Sorting
      default_sort = case price_source
        when "guide"   then "adjusted_value"
        when "my"      then "personal_value"
        when "discogs" then "discogs_value"
        else "best_value"
      end
      sort_col = params[:sort] || default_sort
      direction = params[:direction] == "asc" ? "ASC" : "DESC"
      records = records.order(Arel.sql("#{sort_sql_for(sort_col)} #{direction} NULLS LAST"))

      top_n = params[:top_n].to_i
      top_n = nil unless [100, 500, 1000, 2000].include?(top_n)

      respond_to do |format|
        format.html do
          if top_n
            total = [records.unscope(:select, :order).count, top_n].min
            @pagy = Pagy.new(count: total, limit: 50, page: params[:page], overflow: :last_page)
            @records = records.offset(@pagy.offset).limit(@pagy.limit)
          else
            @pagy, @records = pagy(records, limit: 50)
          end
          @stats = compute_stats(base)
          load_filter_options
        end
        format.csv do
          send_csv_export(records.limit(top_n || 10_000))
        end
      end
    end

    def show
      @record_with_valuation = Record.where(id: @record.id).with_valuation.first
      @conditions = Record.conditions.keys
      @genres = Genre.order(:name)
      @formats = RecordFormat.order(:name)
    end

    def edit
      redirect_to admin_record_path(@record)
    end

    def update
      if @record.update(admin_record_params)
        redirect_to admin_record_path(@record), notice: "Record updated."
      else
        @record_with_valuation = Record.where(id: @record.id).with_valuation.first
        @conditions = Record.conditions.keys
        @genres = Genre.order(:name)
        @formats = RecordFormat.order(:name)
        render :show, status: :unprocessable_entity
      end
    end

    def destroy
      @record.destroy
      redirect_to admin_records_path, notice: "Record deleted."
    end

    def preview
      render partial: "preview_card", layout: false
    end

    def add_images
      cleaned_images = Array.wrap(params.dig(:record, :images)).reject(&:blank?)
      if cleaned_images.any?
        @record.images.attach(cleaned_images)
        redirect_to admin_record_path(@record), notice: "Images added."
      else
        redirect_to admin_record_path(@record), alert: "No images selected."
      end
    end

    def add_songs
      cleaned_songs = Array.wrap(params.dig(:record, :songs)).reject(&:blank?)
      if cleaned_songs.any?
        @record.songs.attach(cleaned_songs)
        redirect_to admin_record_path(@record), notice: "Audio added."
      else
        redirect_to admin_record_path(@record), alert: "No audio files selected."
      end
    end

    def destroy_attachment
      blob = ActiveStorage::Blob.find_signed(params[:blob_signed_id])
      if blob.nil?
        redirect_to admin_record_path(@record), alert: "Invalid or expired attachment link."
        return
      end
      matching_attachments = blob.attachments.where(record_type: "Record", record_id: @record.id).to_a
      if matching_attachments.empty?
        redirect_to admin_record_path(@record), alert: "Invalid or expired attachment link."
        return
      end
      matching_attachments.each(&:purge)
      redirect_to admin_record_path(@record), notice: "Attachment removed."
    rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
      redirect_to admin_record_path(@record), alert: "Invalid or expired attachment link."
    end

    private

    def set_record
      @record = Record.where(user_id: COLLECTION_USER_ID).find(params[:id])
    end

    def admin_record_params
      params.require(:record).permit(:value, :condition, :comment, :artist_id, :label_id, :genre_id, :record_format_id, :price_id)
    end

    def compute_stats(base_scope)
      valuation_scope = base_scope.with_valuation

      total_count = base_scope.count
      total_value = base_scope
        .joins("LEFT JOIN prices ON prices.id = records.price_id")
        .joins("LEFT JOIN discogs_releases ON discogs_releases.id = records.discogs_release_id")
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

      raw_formats = RecordFormat.joins(:records)
                                .where(records: { user_id: COLLECTION_USER_ID })
                                .group("record_formats.name")
                                .pluck("record_formats.name", Arel.sql("COUNT(records.id)"))
      category_counts = raw_formats.each_with_object(Hash.new(0)) do |(name, count), h|
        h[name.split(":").first.strip] += count
      end
      @format_categories = category_counts.sort_by { |_, count| -count }
                                          .map { |name, count| { name: name, count: count } }

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

      rows = records.to_a

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
            sanitize_csv_cell(r[:artist_name]),
            sanitize_csv_cell(r[:label_name]),
            sanitize_csv_cell(r[:genre_name]),
            sanitize_csv_cell(r[:format_name]),
            sanitize_csv_cell(r[:price_detail]),
            sanitize_csv_cell(r.condition&.titleize || "N/A"),
            r[:price_low],
            r[:price_high],
            r[:personal_value],
            r[:adjusted_value].to_f.round(0),
            r[:best_value].to_f.round(0),
            r[:discogs_lowest_price],
            confidence,
            ratio_str,
            sanitize_csv_cell(r.comment),
            sanitize_csv_cell(r[:price_footnote])
          ]
        end
      end

      send_data csv_data,
        filename: "value_explorer_#{Date.current}.csv",
        type: "text/csv",
        disposition: "attachment"
    end

    def sanitize_csv_cell(value)
      return value unless value.is_a?(String)
      value.start_with?("=", "+", "-", "@", "\t", "\r", "\n") ? "'#{value}" : value
    end
  end
end
