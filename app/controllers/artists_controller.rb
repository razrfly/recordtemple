class ArtistsController < ApplicationController

  def index
    respond_to do |format|
      format.html do
        @artists = Artist.active.page(params[:page])
      end

      format.json do
        @artists = Artist.fuzzy_search(name: params[:q])
        render json: @artists.as_json(only: [:id, :name])
      end
    end
  end

  def show
    @artist = Artist.find(params[:id])
  end

end
