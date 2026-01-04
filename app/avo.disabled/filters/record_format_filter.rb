class RecordFormatFilter < Avo::Filters::SelectFilter
  self.name = "Record format filter"
  # self.visible = -> do
  #   true
  # end

  def apply(request, query, value)
    query = query.where(record_format_id: value) if value.present?
    query
  end

  def options
    RecordFormat.pluck(:id, :name).to_h
  end
end
