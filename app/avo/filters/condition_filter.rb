class ConditionFilter < Avo::Filters::SelectFilter
  self.name = "Condition filter"
  # self.visible = -> do
  #   true
  # end

  def apply(request, query, value)
    query = query.where(condition: value) if value.present?
    query
  end

  def options
    Record.conditions.invert
  end
end
