class StatisticsController < ApplicationController
  def index
    @genres = Record.select("DISTINCT genre_id, COUNT(*)").group("genre_id")
  end

end
