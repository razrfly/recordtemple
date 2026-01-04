# frozen_string_literal: true

require "aws-sdk-s3"

# Migrates a single Photo or Song from Refile (cdn.recordtemple.com) to Active Storage.
# Designed for parallel execution via Sidekiq.
#
# Features:
# - Idempotent: checks if blob already exists by refile_id in metadata
# - Blob reuse: if file already migrated, just attaches existing blob
# - Direct S3 access for reliability
#
# Usage:
#   MigrateRefileJob.perform_async('Photo', 123)
#   MigrateRefileJob.perform_async('Song', 456)
#
class MigrateRefileJob
  include Sidekiq::Job

  sidekiq_options queue: :migration, retry: 3

  OLD_BUCKET = "cdn.recordtemple.com"
  REGION = "us-east-1"

  def perform(asset_type, asset_id)
    case asset_type
    when "Photo"
      migrate_photo(asset_id)
    when "Song"
      migrate_song(asset_id)
    else
      logger.warn "Unknown asset type: #{asset_type}"
    end
  end

  private

  def migrate_photo(photo_id)
    photo = Photo.includes(:record).find_by(id: photo_id)
    return unless photo&.record && photo.image_id.present?

    refile_id = photo.image_id
    record = photo.record

    # Check if blob already exists
    existing_blob = find_existing_blob(refile_id)

    if existing_blob
      # Check if already attached to this record
      return if record.images.blobs.exists?(existing_blob.id)

      # Reuse existing blob
      record.images.attach(existing_blob)
      logger.info "Photo #{photo_id}: Reused existing blob for refile_id #{refile_id}"
    else
      # Download and upload new blob
      file_data = download_from_s3(refile_id)
      return unless file_data

      record.images.attach(
        io: StringIO.new(file_data),
        filename: photo.image_filename || "image.jpg",
        content_type: photo.image_content_type || "image/jpeg",
        identify: false,
        metadata: { refile_id: refile_id }
      )
      logger.info "Photo #{photo_id}: Uploaded new blob for refile_id #{refile_id}"
    end
  rescue ActiveRecord::RecordNotFound
    logger.warn "Photo #{photo_id}: Record not found"
  rescue StandardError => e
    logger.error "Photo #{photo_id}: #{e.class} - #{e.message}"
    raise # Re-raise for Sidekiq retry
  end

  def migrate_song(song_id)
    song = Song.includes(:record).find_by(id: song_id)
    return unless song&.record && song.audio_id.present?

    refile_id = song.audio_id
    record = song.record

    # Check if blob already exists
    existing_blob = find_existing_blob(refile_id)

    if existing_blob
      # Check if already attached to this record
      return if record.songs.blobs.exists?(existing_blob.id)

      # Reuse existing blob
      record.songs.attach(existing_blob)
      logger.info "Song #{song_id}: Reused existing blob for refile_id #{refile_id}"
    else
      # Download and upload new blob
      file_data = download_from_s3(refile_id)
      return unless file_data

      record.songs.attach(
        io: StringIO.new(file_data),
        filename: song.audio_filename || "audio.mp3",
        content_type: song.audio_content_type || "audio/mpeg",
        identify: false,
        metadata: { refile_id: refile_id }
      )
      logger.info "Song #{song_id}: Uploaded new blob for refile_id #{refile_id}"
    end
  rescue ActiveRecord::RecordNotFound
    logger.warn "Song #{song_id}: Record not found"
  rescue StandardError => e
    logger.error "Song #{song_id}: #{e.class} - #{e.message}"
    raise # Re-raise for Sidekiq retry
  end

  def find_existing_blob(refile_id)
    # Query for blob with matching refile_id in metadata
    # metadata column is text (not jsonb), so we cast to json first
    ActiveStorage::Blob.where("metadata::json->>'refile_id' = ?", refile_id).first
  end

  def download_from_s3(refile_id)
    s3_key = "store/#{refile_id}"
    response = s3_client.get_object(bucket: OLD_BUCKET, key: s3_key)
    response.body.read
  rescue Aws::S3::Errors::NotFound
    logger.warn "S3 file not found: #{s3_key}"
    nil
  rescue Aws::S3::Errors::ServiceError => e
    logger.error "S3 error for #{s3_key}: #{e.message}"
    raise # Re-raise for retry
  end

  def s3_client
    @s3_client ||= Aws::S3::Client.new(
      region: REGION,
      credentials: Aws::Credentials.new(
        Rails.application.credentials.dig(:aws, :access_key_id),
        Rails.application.credentials.dig(:aws, :secret_access_key)
      )
    )
  end
end
