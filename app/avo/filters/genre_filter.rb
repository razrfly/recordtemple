class GenreFilter < Avo::Filters::SelectFilter
  self.name = "Genre filter"
  # self.visible = -> do
  #   true
  # end

  def apply(request, query, value)
    query = query.where(genre_id: value) if value.present?
    query
  end

  def options
    Genre.pluck(:id, :name).to_h
  end
end
