module ApplicationHelper

  def photo_link_helper target, width = nil, height = nil
    create_link_for = Proc.new do |target|
      link_to attachment_image_tag(target, :image, :fit, width, height,
        class: 'img-responsive'), attachment_url(target, :image),
        class: 'image-link'
    end

    if target.is_a?(Photo)
      create_link_for.(target)
    elsif target.photos.present?
      create_link_for.(target.photos.first)
    else
      image_tag fallback(width, height), class: 'img-responsive'
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
