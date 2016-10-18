class GenresController < ApplicationController
  include SearchQueryHelper

  before_action :set_genre, only: [:show]

  def show
    @q = Record.where('genre_id': @genre.id).
      ransack(query_params)

    records_search_results(@q)
    remember_last_search_query
  end

  private

  def set_genre
    @genre = Genre.find(params[:id])
  end
end

