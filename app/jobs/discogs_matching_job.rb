# frozen_string_literal: true

# Matches a single record to Discogs.
# For batch processing, use DiscogsMatchingJob.match_all!
#
# Usage:
#   DiscogsMatchingJob.perform_later(record_id)
#   DiscogsMatchingJob.match_all!(limit: 100)
#
class DiscogsMatchingJob < ApplicationJob
  queue_as :discogs

  # Discard if record was deleted before job ran
  discard_on ActiveRecord::RecordNotFound

  # Retry on rate limit errors with exponential backoff
  retry_on DiscogsApiClient::RateLimitError, wait: :polynomially_longer, attempts: 5

  # Retry on transient errors
  retry_on DiscogsApiClient::Error, wait: 30.seconds, attempts: 3
  retry_on ActiveRecord::Deadlocked, wait: :polynomially_longer, attempts: 3

  def perform(record_id)
    record = Record.find(record_id)

    # Skip if already matched
    if record.discogs_release_id.present?
      Rails.logger.debug { "[DiscogsMatchingJob] Record ##{record_id} already matched, skipping" }
      return
    end

    service = DiscogsMatchingService.new(record)
    release = service.match!

    if release
      Rails.logger.info { "[DiscogsMatchingJob] Matched record ##{record_id} to Discogs #{release.discogs_id} (confidence: #{record.reload.discogs_confidence}%)" }
    else
      Rails.logger.debug { "[DiscogsMatchingJob] No match found for record ##{record_id}" }
    end
  end

  class << self
    # Batch match unmatched records
    # Options:
    #   limit: Maximum records to process (default: all)
    #   skip_low_confidence: Only auto_high matches (default: false)
    #   user_id: Only match records for specific user
    #   dry_run: Don't actually match, just log candidates
    def match_all!(limit: nil, skip_low_confidence: false, user_id: nil, dry_run: false)
      scope = Record.discogs_unmatched.includes(:artist, :label, :record_format, :price)
      scope = scope.where(user_id: user_id) if user_id

      # Note: find_each ignores limit, so we use each with limit instead
      records = limit ? scope.limit(limit).to_a : scope.to_a
      total = records.size
      matched = 0
      skipped = 0
      no_match = 0

      Rails.logger.info { "[DiscogsMatchingJob] Starting batch match for #{total} records" }

      records.each_with_index do |record, index|
        if index > 0 && (index % 100).zero?
          Rails.logger.info { "[DiscogsMatchingJob] Progress: #{index}/#{total} (matched: #{matched}, skipped: #{skipped}, no_match: #{no_match})" }
        end

        begin
          service = DiscogsMatchingService.new(record)
          candidates = service.find_candidates(limit: 3)

          if candidates.empty?
            no_match += 1
            next
          end

          best = candidates.first
          threshold = skip_low_confidence ? DiscogsMatchingService::THRESHOLDS[:auto_high] : DiscogsMatchingService::THRESHOLDS[:auto_low]

          if best[:score] < threshold
            skipped += 1
            Rails.logger.debug { "[DiscogsMatchingJob] Record ##{record.id}: best score #{best[:score]} below threshold #{threshold}" }
            next
          end

          if dry_run
            Rails.logger.info { "[DiscogsMatchingJob] DRY RUN - Would match record ##{record.id} to #{best[:candidate]['id']} (score: #{best[:score]})" }
            matched += 1
          else
            # Pass pre-fetched candidates to avoid redundant API calls
            release = service.match!(candidates: candidates)
            if release
              matched += 1
            else
              skipped += 1
            end
          end

        rescue DiscogsApiClient::RateLimitError => e
          Rails.logger.warn { "[DiscogsMatchingJob] Rate limited at record ##{record.id}, waiting..." }
          sleep(60)
          retry
        rescue DiscogsApiClient::Error => e
          Rails.logger.error { "[DiscogsMatchingJob] API error for record ##{record.id}: #{e.message}" }
          skipped += 1
        end
      end

      summary = {
        total: total,
        matched: matched,
        skipped: skipped,
        no_match: no_match,
        match_rate: total.positive? ? (matched.to_f / total * 100).round(1) : 0
      }

      Rails.logger.info { "[DiscogsMatchingJob] Batch complete: #{summary}" }
      summary
    end

    # Queue all unmatched records for background processing
    def enqueue_all!(limit: nil, user_id: nil)
      scope = Record.discogs_unmatched
      scope = scope.where(user_id: user_id) if user_id

      # Note: find_each ignores limit, so we use find_in_batches with take
      record_ids = limit ? scope.limit(limit).pluck(:id) : scope.pluck(:id)

      record_ids.each do |id|
        perform_later(id)
      end

      Rails.logger.info { "[DiscogsMatchingJob] Enqueued #{record_ids.size} records for matching" }
      record_ids.size
    end
  end
end
