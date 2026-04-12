module Api
  class ArtistsController < ApplicationController
    def index
      query = params[:q].to_s.strip

      return render json: [] if query.length < 2

      sanitized = ActiveRecord::Base.sanitize_sql_like(query)

      artists = Artist
        .left_joins(:records)
        .where("artists.name ILIKE ?", "%#{sanitized}%")
        .group("artists.id")
        .order(
          Arel.sql("CASE " \
            "WHEN artists.name ILIKE #{Artist.connection.quote(sanitized)} THEN 0 " \
            "WHEN artists.name ILIKE #{Artist.connection.quote("#{sanitized}%")} THEN 1 " \
            "ELSE 2 END"),
          Arel.sql("LENGTH(artists.name)"),
          :name
        )
        .limit(10)
        .select("artists.id, artists.name, COUNT(records.id) AS record_count")

      render json: artists.map { |a|
        { id: a.id, name: a.name, count: a.record_count }
      }
    end

    def create
      artist = Artist.find_or_create_by!(name: params[:name].to_s.strip)
      render json: { id: artist.id, name: artist.name }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

  end
end
