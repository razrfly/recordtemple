module RecordsHelper

  def thumb_tag(record)
    unless record.photos.blank?
      image_tag(record.photos.first.data(:small), :size => '250x150')
    end
  end
end
