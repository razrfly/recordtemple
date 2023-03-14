class AssetFilter < Avo::Filters::BooleanFilter
  self.name = "Asset filter"
  # self.visible = -> do
  #   true
  # end

  def apply(request, query, values)
    if values['has_images']
      query = query.has_images
    elsif values['has_songs']
      query = query.has_songs
    end

    query
  end

  def options
    {
      has_images: "Has images",
      has_songs: "Has audio"
    }
  end
end
