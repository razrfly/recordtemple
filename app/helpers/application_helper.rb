module ApplicationHelper
  include Pagy::Frontend

  # Generate CDN URL for Active Storage variants
  # Falls back to Rails representation URL in development or if variant not processed
  def cdn_image_url(variant)
    return rails_representation_url(variant) unless Rails.env.production?

    # Process the variant if needed and get its key
    variant.processed
    "https://cdn4.recordtemple.com/#{variant.key}"
  rescue StandardError
    # Fallback to Rails URL if anything goes wrong
    rails_representation_url(variant)
  end

  # Generate CDN URL for original blobs (unprocessed attachments)
  def cdn_blob_url(blob)
    return rails_blob_url(blob) unless Rails.env.production?

    "https://cdn4.recordtemple.com/#{blob.key}"
  rescue StandardError
    rails_blob_url(blob)
  end
end
