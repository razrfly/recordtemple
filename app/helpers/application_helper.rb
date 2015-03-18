module ApplicationHelper

  def admin?
    controller.class.name.split("::").first=="Admin"
  end

  def real_currency(number)
    number_to_currency(number, :delimiter => ".", :unit => "$", :separator => ".")
  end

  def cover_link_for target
    unless target.cover_photo.blank?
      link_to image_tag(target.cover_photo), (admin? ? [:admin, target] : target)
    end
  end

end
