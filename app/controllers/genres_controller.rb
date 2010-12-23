class GenresController < ApplicationController
  def index
    @genres = Genre.all
    if params[:order] == "value"
      @stats = current_user.records.select("DISTINCT genre_id, COUNT(*), SUM(value)").group("genre_id").order("count DESC")
    else
      @stats = current_user.records.select("DISTINCT genre_id, COUNT(*), SUM(value)").group("genre_id").order("sum DESC")
    end
  end

  def show
  end

end
