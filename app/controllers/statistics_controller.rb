class StatisticsController < ApplicationController
  def index
    @genres = Record.select("DISTINCT genre_id, COUNT(*), SUM(value)").group("genre_id").order("count DESC").limit(8)
    @genre_list = Genre.limit(5)
    @genre_value = Record.limit(10).order("VALUE DESC")
  end

end
