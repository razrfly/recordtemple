module ApplicationHelper

  def real_currency(number)
    number_to_currency(number, :delimiter => ".", :unit => "$", :separator => ".")
  end

  def cover_link_for target
    unless target.cover_photo.blank?
      link_to target do
        image_tag target.cover_photo
      end
    end
  end

end
