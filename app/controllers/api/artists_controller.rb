module Api
  class ArtistsController < ApplicationController
    def index
      query = params[:q].to_s.strip

      return render json: [] if query.length < 2

      artists = Artist
        .left_joins(:records)
        .where("artists.name ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(query)}%")
        .group("artists.id")
        .order(:name)
        .limit(10)
        .select("artists.id, artists.name, COUNT(records.id) AS record_count")

      render json: artists.map { |a|
        { id: a.id, name: a.name, count: a.record_count }
      }
    end

  end
end
