class GenresController < ApplicationController

  def show
    @genre = Genre.find(params[:id])
    @search = @genre.records.ransack(params[:q])
    @records = @search.result.page(params[:page])
    # fix to POPULAR artists
    @artists = Artist.joins(:records => :genre).where('genres.id = ?', @genre.id).uniq
  end

end

