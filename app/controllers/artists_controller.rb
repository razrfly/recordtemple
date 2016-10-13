class ArtistsController < ApplicationController
  include SearchQueryHelper

  before_action :set_artist, only: [:show]

  def index
    @q = Artist.ransack(query_params)

    @result = @q.result.
      includes(:photos).
      uniq

    respond_to do |format|
      format.html do
        @artists = query_params.blank? ? Artist.active : @result

        @artists = @artists.page(params[:page])
      end

      format.json do
        @artists = Artist.fuzzy_search(name: params[:q]).uniq
        render json: @artists.as_json(only: [:id, :name])
      end
    end
  end

  def show
    @q = Record.where('artist_id': @artist.id).
      ransack(query_params)

    @records = @q.result.includes(
      :price, :genre, :artist, :photos,
      :songs, :record_format => :record_type
    ).uniq
    .page(params[:page])

    @last_search_query = session[:last_search_query]
  end

  private

  def set_artist
    @artist = Artist.find(params[:id])
  end
end
