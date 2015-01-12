class GenresController < ApplicationController
  before_action :set_genre, :only => [:show, :edit, :update, :destroy]

  def index
    @genres = Genre.all
  end

  def show
    @genre = Genre.find(params[:id])
  end

end
