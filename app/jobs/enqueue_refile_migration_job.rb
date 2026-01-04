# frozen_string_literal: true

# Enqueues all pending Photo and Song migrations as individual Sidekiq jobs.
# Uses perform_bulk for efficient Redis operations.
#
# Features:
# - Skips already-migrated files (by checking blob metadata)
# - Bulk enqueues in batches of 1000 for efficiency
# - Reports progress and totals
#
# Usage:
#   EnqueueRefileMigrationJob.perform_async
#
# Or run synchronously in console:
#   EnqueueRefileMigrationJob.new.perform
#
class EnqueueRefileMigrationJob
  include Sidekiq::Job

  sidekiq_options queue: :default, retry: 0

  BULK_SIZE = 1000

  def perform
    logger.info "=" * 70
    logger.info "ENQUEUING REFILE MIGRATION JOBS"
    logger.info "=" * 70

    # Get already migrated refile_ids from blob metadata
    migrated_refile_ids = Set.new
    ActiveStorage::Blob.where.not(metadata: nil).find_each do |blob|
      refile_id = blob.metadata["refile_id"]
      migrated_refile_ids.add(refile_id) if refile_id.present?
    end
    logger.info "Found #{migrated_refile_ids.size} already-migrated blobs (will skip)"

    # Collect photo jobs
    photo_jobs = []
    Photo.where.not(image_id: nil).pluck(:id, :image_id).each do |photo_id, image_id|
      next if migrated_refile_ids.include?(image_id)
      photo_jobs << ["Photo", photo_id]
    end
    logger.info "Photos to migrate: #{photo_jobs.size}"

    # Collect song jobs
    song_jobs = []
    Song.where.not(audio_id: nil).pluck(:id, :audio_id).each do |song_id, audio_id|
      next if migrated_refile_ids.include?(audio_id)
      song_jobs << ["Song", song_id]
    end
    logger.info "Songs to migrate: #{song_jobs.size}"

    total_jobs = photo_jobs.size + song_jobs.size
    logger.info "Total jobs to enqueue: #{total_jobs}"

    if total_jobs == 0
      logger.info "Nothing to enqueue - all files already migrated!"
      return
    end

    # Bulk enqueue photos
    enqueue_in_batches(photo_jobs, "Photo")

    # Bulk enqueue songs
    enqueue_in_batches(song_jobs, "Song")

    logger.info "=" * 70
    logger.info "ENQUEUE COMPLETE"
    logger.info "  Total jobs enqueued: #{total_jobs}"
    logger.info "  Queue: migration"
    logger.info "  Monitor: Sidekiq::Queue.new('migration').size"
    logger.info "=" * 70
  end

  private

  def enqueue_in_batches(jobs, type)
    return if jobs.empty?

    jobs.each_slice(BULK_SIZE).with_index do |batch, batch_idx|
      Sidekiq::Client.push_bulk(
        "class" => MigrateRefileJob,
        "args" => batch,
        "queue" => "migration"
      )
      logger.info "  Enqueued #{type} batch #{batch_idx + 1}: #{batch.size} jobs"
    end
  end
end
