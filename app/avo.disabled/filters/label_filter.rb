class LabelFilter < Avo::Filters::TextFilter
  self.name = "Label filter"
  self.button_label = 'Filter by label'
  # self.visible = -> do
  #   true
  # end

  def apply(request, query, value)
    query.joins(:label).where('LOWER(labels.name) LIKE ?', "%#{value}%")
  end
end
