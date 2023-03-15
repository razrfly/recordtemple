class GenreChart < Avo::Dashboards::ChartkickCard
  self.id = "genre_chart"
  self.label = "Genre chart"
  self.chart_type = :pie_chart
  self.cols = 1
  self.rows = 2
  self.flush = false
  self.legend = true
  self.scale = true
  self.legend_on_left = true
  self.visible = -> {
    true
  }

  def query
    result Record.joins(:genre).group("genres.name").count.to_a
  end
end
