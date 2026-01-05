module Api
  class ArtistsController < ApplicationController
    COLLECTION_USER_ID = 1

    def index
      query = params[:q].to_s.strip

      return render json: [] if query.length < 2

      artists = Artist
        .joins(:records)
        .where(records: { user_id: COLLECTION_USER_ID })
        .where("artists.name ILIKE ?", "%#{sanitize_sql_like(query)}%")
        .group("artists.id")
        .order(Arel.sql("COUNT(records.id) DESC"))
        .limit(10)
        .select("artists.id, artists.name, COUNT(records.id) AS record_count")

      render json: artists.map { |a|
        { id: a.id, name: a.name, count: a.record_count }
      }
    end

    private

    def sanitize_sql_like(string)
      string.gsub(/[\\%_]/) { |x| "\\#{x}" }
    end
  end
end
