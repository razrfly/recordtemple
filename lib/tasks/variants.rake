namespace :variants do
  desc "Queue all image variants for pre-warming via Sidekiq"
  task warmup: :environment do
    puts "Queuing variant warmup jobs..."

    # Get all image blobs attached to records
    blob_ids = ActiveStorage::Attachment
      .where(record_type: "Record", name: "images")
      .pluck(:blob_id)
      .uniq

    total = blob_ids.count
    puts "Found #{total} image blobs to process"

    blob_ids.each_with_index do |blob_id, index|
      VariantWarmupJob.perform_later(blob_id)

      if (index + 1) % 1000 == 0
        puts "Queued #{index + 1}/#{total} jobs..."
      end
    end

    puts "Done! Queued #{total} variant warmup jobs."
    puts "Monitor progress with: fly logs -a recordtemple"
  end

  desc "Warmup variants synchronously (for testing, slower)"
  task warmup_sync: :environment do
    puts "Processing variants synchronously..."

    blobs = ActiveStorage::Attachment
      .where(record_type: "Record", name: "images")
      .includes(:blob)
      .limit(ENV.fetch("LIMIT", 100).to_i)

    total = blobs.count
    puts "Processing #{total} images..."

    blobs.each_with_index do |attachment, index|
      blob = attachment.blob
      next unless blob&.image?

      VariantWarmupJob::VARIANT_SIZES.each do |options|
        begin
          blob.variant(options).processed
          print "."
        rescue => e
          print "x"
          Rails.logger.error "Failed: blob #{blob.id} with #{options}: #{e.message}"
        end
      end

      if (index + 1) % 10 == 0
        puts " #{index + 1}/#{total}"
      end
    end

    puts "\nDone!"
  end

  desc "Count how many variants need to be generated"
  task status: :environment do
    total_blobs = ActiveStorage::Attachment
      .where(record_type: "Record", name: "images")
      .count

    total_variants = ActiveStorage::VariantRecord.count

    expected_variants = total_blobs * VariantWarmupJob::VARIANT_SIZES.count
    missing = expected_variants - total_variants

    puts "Image blobs: #{total_blobs}"
    puts "Variant sizes: #{VariantWarmupJob::VARIANT_SIZES.count}"
    puts "Expected variants: #{expected_variants}"
    puts "Existing variants: #{total_variants}"
    puts "Missing variants: #{missing} (#{(missing.to_f / expected_variants * 100).round(1)}%)"
  end
end
