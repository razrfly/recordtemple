class Main < Avo::Dashboards::BaseDashboard
  self.id = "main"
  self.name = "Main"
  self.description = "RecordTemple Overview"
  # self.grid_cols = 3
  # self.visible = -> do
  #   true
  # end

  # cards go here
  card GenreChart
  card RecordFormatChart
end
