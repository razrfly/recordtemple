class ArtistsController < ApplicationController

  def index
    @search = Artist.ransack(params[:q])
    @artists = @search.result.page(params[:page])

    respond_to do |format|
      format.html
      format.json { render json: @artists.to_json(only: [:name, :id]) }
    end
  end

  def show
    @artist = Artist.find(params[:id])
  end

end
