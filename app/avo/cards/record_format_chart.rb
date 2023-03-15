class RecordFormatChart < Avo::Dashboards::ChartkickCard
  self.id = "record_format_chart"
  self.label = "Record format chart"
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
    result Record.joins(:record_format).group("record_formats.name").having("COUNT(record_formats.*) > 100").count.to_a
  end
end
