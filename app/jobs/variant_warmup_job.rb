class VariantWarmupJob < ApplicationJob
  queue_as :default

  # All variant sizes used across the app
  VARIANT_SIZES = [
    { resize_to_fill: [ 96, 96 ] },    # lightbox thumbnails
    { resize_to_fill: [ 160, 160 ] },  # record show thumbnails
    { resize_to_fill: [ 200, 200 ] },  # discovery cards
    { resize_to_fill: [ 200, 400 ] },  # discovery cards tall
    { resize_to_fill: [ 320, 320 ] },  # artist/label/genre covers
    { resize_to_fill: [ 400, 400 ] },  # record cards
    { resize_to_fill: [ 600, 600 ] },  # record show hero
    { resize_to_limit: [ 1200, 1200 ] } # lightbox full size
  ].freeze

  def perform(blob_id, variant_options = nil)
    blob = ActiveStorage::Blob.find_by(id: blob_id)
    return unless blob&.image?

    sizes = variant_options ? [ variant_options ] : VARIANT_SIZES

    sizes.each do |options|
      begin
        # This generates and uploads the variant to S3 if it doesn't exist
        blob.variant(options).processed
      rescue => e
        Rails.logger.error "Failed to process variant for blob #{blob_id} with #{options}: #{e.message}"
      end
    end
  end
end
