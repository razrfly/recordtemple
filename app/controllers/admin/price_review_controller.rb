# frozen_string_literal: true

module Admin
  class PriceReviewController < BaseController
    before_action :set_record, only: [:show, :search, :link, :clear]

    # GET /admin/price_review/:id
    def show
      @auto_query = @record.artist&.name.to_s
      @candidates = price_search(@auto_query)
    end

    # POST /admin/price_review/:id/search
    def search
      @auto_query = @record.artist&.name.to_s
      query = params[:query].presence || @auto_query
      @candidates = price_search(query)
      render :show
    end

    # POST /admin/price_review/:id/link
    def link
      price_id = params[:price_id].to_i
      return redirect_with_error("Invalid Price ID") if price_id <= 0

      price = Price.find_by(id: price_id)
      return redirect_with_error("Price ##{price_id} not found") unless price

      @record.update!(price: price)
      redirect_to admin_record_path(@record), notice: "Price linked successfully."
    rescue => e
      Rails.logger.error("Price link failed: #{e.class} - #{e.message}")
      redirect_with_error("Link failed, please try again.")
    end

    # POST /admin/price_review/:id/clear
    def clear
      @record.update!(price: nil)
      redirect_to admin_record_path(@record), notice: "Price link cleared."
    rescue => e
      Rails.logger.error("Price clear failed: #{e.class} - #{e.message}")
      redirect_with_error("Clear failed, please try again.")
    end

    private

    def set_record
      @record = Record.find(params[:id])
    end

    def price_search(query)
      return [] if query.blank?

      tokens = query.split.map { |t| "%#{sanitize_sql_like(t)}%" }

      scope = Price.all
      tokens.each do |token|
        scope = scope.where(
          "cached_artist ILIKE :t OR cached_label ILIKE :t OR detail ILIKE :t",
          t: token
        )
      end
      scope.order(price_high: :desc).limit(10)
    end

    def sanitize_sql_like(str)
      str.gsub(/[\\%_]/) { |c| "\\#{c}" }
    end

    def redirect_with_error(message)
      redirect_to admin_price_review_path(@record), alert: message
    end
  end
end
