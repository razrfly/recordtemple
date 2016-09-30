module RecordsHelper

  def thumb_tag(record)
    unless record.photos.blank?
      image_tag(record.photos.first.data(:small), :size => '250x150')
    end
  end

  def condition_formatter(condition)
    rules = {'_' => ' ', 'plus' => '+'}

    condition.gsub(/_|plus/, rules)
  end
end
