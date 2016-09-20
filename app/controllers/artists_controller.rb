class ArtistsController < ApplicationController

  def index
    @q = Artist.ransack(query_params)

    @result = @q.result.
      includes(:records, :photos).
      uniq

    respond_to do |format|
      format.html do
        @artists = @result.page(params[:page])
      end

      format.json do
        @artists = Artist.joins(:records).fuzzy_search(name: params[:q]).uniq
        render json: @artists.as_json(only: [:id, :name])
      end
    end
  end

  def show
    @artist = Artist.find(params[:id])
  end

  private

  def query_params
    params[:q].try(:reject) do |k, v|
      ['photos_id_not_null', 'songs_id_not_null'].include?(k) && v == '0'
    end
  end
end
