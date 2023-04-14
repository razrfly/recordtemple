class ArtistFilter < Avo::Filters::TextFilter
  self.name = "Artist filter"
  self.button_label = 'Filter by artist'
  # self.visible = -> do
  #   true
  # end

  def apply(request, query, value)
    query.joins(:artist).where('LOWER(artists.name) LIKE ?', "%#{value}%")
  end
end
