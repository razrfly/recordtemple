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

  def markdown(content)
    settings = Redcarpet::Render::HTML.new(with_toc_data: true, filter_html: true)
    markdown = Redcarpet::Markdown.new(settings,
        autolink: true, space_after_headers: true, autolink: true, hard_wrap: true,
        no_intraemphasis: true, strikethrough: true, tables: true, footnotes: true)
    unless content.blank?
      return markdown.render(content).html_safe
    end
  end

end
