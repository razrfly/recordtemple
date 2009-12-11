module RecordsHelper
  def mugshot_for(record, size = :medium)
    if record.mugshot 
      mugshot_image = record.mugshot.public_filename(size)
      link_to image_tag(mugshot_image), record.mugshot.public_filename
    else
      image_tag("blank-mugshot-#{size}.png")
    end
  end
  
end
