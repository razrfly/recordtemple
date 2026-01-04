class PublishedFilter < Avo::Filters::SelectFilter
  self.name = "Published filter"
  # self.visible = -> do
  #   true
  # end

  def apply(request, query, value)
    case value
    when 'with_records'
      query.with_records
    when 'with_records_and_images'
      query.with_records_and_images
    else
      query.all
    end
  end

  def options
    {
      all: "All",
      with_records: "With records",
      with_records_and_images: "With records and images"
      
    }
  end

  def default
    'with_records_and_images'
  end
end
