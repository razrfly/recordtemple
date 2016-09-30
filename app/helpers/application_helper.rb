module ApplicationHelper

  def cover_link_for target
    if target.cover_photo.present?
      link_to image_tag(target.cover_photo), (admin? ? [:admin, target] : target)
    else
      "No cover"
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

  def gravatar_url(user)
    gravatar_id = Digest::MD5::hexdigest(user.email).downcase
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=48"
  end

  def fallback(width, height)
    "https://placehold.it/#{width}x#{height}?text=No image"
  end
end
