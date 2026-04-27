module Api
  class PricesController < ApplicationController
    before_action :require_api_user!, only: [:create]

    def index
      query = params[:q].to_s.strip

      return render json: [] if query.length < 2

      prices = Price
        .where(
          "prices.cached_artist ILIKE :q OR prices.cached_label ILIKE :q OR prices.detail ILIKE :q",
          q: "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
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

    def create
      price = Price.new(price_params.merge(user_id: current_user.id))
      if price.save
        render json: { id: price.id, name: price.title }, status: :created
      else
        render json: { errors: price.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def price_params
      params.require(:price).permit(
        :artist_id, :label_id, :record_format_id,
        :yearbegin, :yearend, :price_low, :price_high,
        :detail, :footnote, :media_type
      )
    end
  end
end
