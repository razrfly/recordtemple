module ApplicationHelper
  include Pagy::Frontend

  # Generate URL for Active Storage variants
  # Uses Rails proxy mode - CDN (CloudFlare) caches the proxied response
  # This is the Rails-recommended approach for CDN integration
  def cdn_image_url(variant)
    rails_representation_url(variant)
  end

  # Generate URL for original blobs (unprocessed attachments)
  def cdn_blob_url(blob)
    rails_blob_url(blob)
  end
end
