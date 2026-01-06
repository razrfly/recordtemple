require "sidekiq/api"

module Admin
  class VariantsController < ApplicationController
    before_action :require_admin!

    def index
      @stats = calculate_stats
    end

    def warmup
      blob_ids = ActiveStorage::Attachment
        .where(record_type: "Record", name: "images")
        .pluck(:blob_id)
        .uniq

      blob_ids.each do |blob_id|
        VariantWarmupJob.perform_later(blob_id)
      end

      redirect_to admin_variants_path, notice: "Queued #{blob_ids.count} warmup jobs"
    end

    def clear_retries
      retry_set = Sidekiq::RetrySet.new
      count = retry_set.size
      retry_set.clear

      redirect_to admin_variants_path, notice: "Cleared #{count} retry jobs"
    end

    def stats
      @stats = calculate_stats
      render partial: "stats", locals: { stats: @stats }
    end

    private

    def require_admin!
      return if current_user&.admin?
      redirect_to root_path, alert: "Not authorized"
    end

    def calculate_stats
      variant_sizes = VariantWarmupJob::VARIANT_SIZES.count

      total_blobs = ActiveStorage::Attachment
        .where(record_type: "Record", name: "images")
        .distinct
        .count(:blob_id)

      variants_created = ActiveStorage::VariantRecord.count
      expected_variants = total_blobs * variant_sizes

      queue = Sidekiq::Queue.new
      retry_set = Sidekiq::RetrySet.new
      processed = Sidekiq::Stats.new

      # Calculate processing rate from Sidekiq stats
      processing_rate = calculate_processing_rate

      # Calculate progress
      progress = expected_variants > 0 ? (variants_created.to_f / expected_variants * 100).round(1) : 0

      # Calculate ETA
      remaining = expected_variants - variants_created
      eta = if processing_rate > 0 && remaining > 0
        seconds = remaining / processing_rate
        format_duration(seconds)
      else
        "Unknown"
      end

      {
        total_blobs: total_blobs,
        variant_sizes: variant_sizes,
        variants_created: variants_created,
        expected_variants: expected_variants,
        queue_size: queue.size,
        retry_count: retry_set.size,
        progress: progress,
        eta: eta,
        processing_rate: processing_rate.round(1),
        processed_today: processed.processed
      }
    end

    def calculate_processing_rate
      # Get jobs processed per second from Sidekiq stats
      # Use the last hour's processing rate
      stats = Sidekiq::Stats.new
      history = Sidekiq::Stats::History.new(1)

      # Get today's processed count
      processed_today = history.processed.values.first || 0

      # Estimate rate based on processed jobs
      # This is a rough estimate - actual rate depends on job timing
      if processed_today > 0
        # Assume jobs have been running and estimate rate
        # Each blob generates 8 variants, so divide by variant count
        (processed_today.to_f / 3600) # Jobs per second over an hour
      else
        0.0
      end
    end

    def format_duration(seconds)
      return "< 1 minute" if seconds < 60

      hours = (seconds / 3600).to_i
      minutes = ((seconds % 3600) / 60).to_i

      parts = []
      parts << "#{hours}h" if hours > 0
      parts << "#{minutes}m" if minutes > 0 || hours == 0

      "~#{parts.join(' ')}"
    end
  end
end
