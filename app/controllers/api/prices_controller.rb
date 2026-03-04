module Api
  class PricesController < ApplicationController
    def index
      query = params[:q].to_s.strip

      return render json: [] if query.length < 2

      prices = Price
        .joins(:artist, :label)
        .where(
          "prices.cached_artist ILIKE :q OR prices.cached_label ILIKE :q OR prices.detail ILIKE :q",
          q: "%#{sanitize_sql_like(query)}%"
        )
        .order("prices.price_high DESC NULLS LAST")
        .limit(10)

      render json: prices.map { |p|
        {
          id: p.id,
          name: p.title,
          count: nil
        }
      }
    end

    private

    def sanitize_sql_like(string)
      string.gsub(/[\\%_]/) { |x| "\\#{x}" }
    end
  end
end
