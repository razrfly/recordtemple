# frozen_string_literal: true

module Admin
  class DiscogsReviewController < ApplicationController
    before_action :require_admin
    before_action :set_record, only: [:show, :search, :link, :skip]

    # GET /admin/discogs_review
    def index
      @scope = params[:scope] || "high_value"
      @records = review_queue_scope
        .includes(:artist, :label, :price, :discogs_release)
        .order("prices.price_high DESC NULLS LAST")
        .page(params[:page])
        .per(25)

      @stats = {
        total: review_queue_scope.count,
        high_value: unmatched_high_value.count,
        medium_value: unmatched_medium_value.count,
        skipped: skipped_records.count
      }
    end

    # GET /admin/discogs_review/:id
    def show
      @candidates = []
    end

    # POST /admin/discogs_review/:id/search
    def search
      query = params[:query].presence || build_search_query(@record)

      begin
        client = DiscogsApiClient.new
        @candidates = client.search(
          query: query,
          type: "release",
          per_page: 10
        )
      rescue => e
        flash.now[:alert] = "Search failed: #{e.message}"
        @candidates = []
      end

      render :show
    end

    # POST /admin/discogs_review/:id/link
    def link
      discogs_id = params[:discogs_id].to_i
      return redirect_with_error("Invalid Discogs ID") if discogs_id <= 0

      begin
        # Fetch the Discogs release
        release_service = DiscogsReleaseService.new
        discogs_release = release_service.find_or_fetch(discogs_id)

        unless discogs_release
          return redirect_with_error("Could not fetch Discogs release ##{discogs_id}")
        end

        # Link with manual method and 100% confidence
        matching_service = DiscogsMatchingService.new(@record)
        matching_service.link!(discogs_release, confidence: 100, method: "manual")

        redirect_to admin_discogs_review_index_path,
          notice: "Linked '#{@record.title}' to Discogs ##{discogs_id}"
      rescue => e
        redirect_with_error("Link failed: #{e.message}")
      end
    end

    # POST /admin/discogs_review/:id/skip
    def skip
      @record.update!(discogs_skip_review: true, discogs_skip_reason: params[:reason])
      redirect_to admin_discogs_review_index_path,
        notice: "Marked '#{@record.title}' as skipped"
    end

    private

    def require_admin
      unless current_user&.admin?
        redirect_to root_path, alert: "Admin access required"
      end
    end

    def set_record
      @record = Record.find(params[:id])
    end

    def review_queue_scope
      case @scope
      when "high_value"
        unmatched_high_value
      when "medium_value"
        unmatched_medium_value
      when "skipped"
        skipped_records
      else
        unmatched_high_value
      end
    end

    def unmatched_high_value
      Record.joins(:price)
        .where(discogs_release_id: nil)
        .where("prices.price_high >= ?", 100)
        .where(discogs_skip_review: [nil, false])
    end

    def unmatched_medium_value
      Record.joins(:price)
        .where(discogs_release_id: nil)
        .where("prices.price_high >= ? AND prices.price_high < ?", 25, 100)
        .where(discogs_skip_review: [nil, false])
    end

    def skipped_records
      Record.where(discogs_skip_review: true)
    end

    def build_search_query(record)
      parts = []
      parts << record.artist&.name if record.artist
      parts << record.title if record.title.present?
      parts.join(" - ")
    end

    def redirect_with_error(message)
      redirect_to admin_discogs_review_path(@record), alert: message
    end
  end
end
