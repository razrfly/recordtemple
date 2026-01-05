# frozen_string_literal: true

# Updates popularity score for a single record.
# Enqueued when attachments are added/removed or record metadata changes.
#
# Usage:
#   RecordPopularityJob.perform_later(record_id)
#
class RecordPopularityJob < ApplicationJob
  queue_as :default

  # Discard if record was deleted before job ran
  discard_on ActiveRecord::RecordNotFound

  # Retry on transient database errors
  retry_on ActiveRecord::Deadlocked, wait: :polynomially_longer, attempts: 3

  def perform(record_id)
    record = Record.find(record_id)

    images_count = record.images.count
    songs_count = record.songs.count
    popularity_score = RecordPopularityCalculator.calculate(record)

    record.update_columns(
      images_count: images_count,
      songs_count: songs_count,
      popularity_score: popularity_score
    )

    Rails.logger.debug { "[RecordPopularityJob] Updated record ##{record_id}: score=#{popularity_score}" }
  end
end
