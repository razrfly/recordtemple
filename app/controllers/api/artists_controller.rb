module Api
  class ArtistsController < ApplicationController
    def index
      query = params[:q].to_s.strip

      return render json: [] if query.length < 2

      artists = Artist
        .where("name ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(query)}%")
        .order(:name)
        .limit(10)

      render json: artists.map { |a|
        { id: a.id, name: a.name }
      }
    end

  end
end
