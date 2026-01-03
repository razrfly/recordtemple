# frozen_string_literal: true

namespace :storage do
  desc "Migrate Refile files from cdn.recordtemple.com to Active Storage on cdn4.recordtemple.com"
  task migrate_refile: :environment do
    require "aws-sdk-s3"

    OLD_BUCKET = "cdn.recordtemple.com"
    REGION = "us-east-1"
    BATCH_LOG_INTERVAL = 500
    PROGRESS_LOG_INTERVAL = 5000

    puts "=" * 70
    puts "REFILE TO ACTIVE STORAGE MIGRATION"
    puts "=" * 70
    puts "Source: s3://#{OLD_BUCKET}/store/*"
    puts "Target: Active Storage (cdn4.recordtemple.com)"
    puts "Started at: #{Time.current}"
    puts "=" * 70

    s3 = Aws::S3::Client.new(
      region: REGION,
      credentials: Aws::Credentials.new(
        Rails.application.credentials.dig(:aws, :access_key_id),
        Rails.application.credentials.dig(:aws, :secret_access_key)
      )
    )

    # Track migrated blobs for deduplication (many photos share same file)
    migrated_blobs = {}
    errors = []
    stats = {
      photos_processed: 0,
      photos_skipped: 0,
      photos_attached: 0,
      photos_reused: 0,
      songs_processed: 0,
      songs_skipped: 0,
      songs_attached: 0,
      songs_reused: 0
    }

    # =======================================================================
    # PHASE 1: MIGRATE PHOTOS → Record.images
    # =======================================================================
    total_photos = Photo.where.not(image_id: nil).count
    puts "\n[PHASE 1] Migrating #{total_photos} photos to Record.images..."
    puts "-" * 70

    Photo.where.not(image_id: nil).includes(:record).find_each.with_index do |photo, i|
      stats[:photos_processed] += 1

      # Skip if no associated record
      unless photo.record
        errors << "Photo #{photo.id}: No associated record (record_id: #{photo.record_id})"
        stats[:photos_skipped] += 1
        next
      end

      refile_id = photo.image_id

      begin
        if migrated_blobs[refile_id]
          # Reuse existing blob for duplicate file
          photo.record.images.attach(migrated_blobs[refile_id])
          stats[:photos_reused] += 1
        else
          # Download from old CDN
          s3_key = "store/#{refile_id}"
          response = s3.get_object(bucket: OLD_BUCKET, key: s3_key)
          file_data = response.body.read

          # Attach to Record via Active Storage
          photo.record.images.attach(
            io: StringIO.new(file_data),
            filename: photo.image_filename || "image.jpg",
            content_type: photo.image_content_type || "image/jpeg",
            identify: false
          )

          # Cache blob for reuse
          migrated_blobs[refile_id] = photo.record.images.blobs.order(:created_at).last
          stats[:photos_attached] += 1
        end

        # Progress logging
        if (i + 1) % BATCH_LOG_INTERVAL == 0
          print "."
        end
        if (i + 1) % PROGRESS_LOG_INTERVAL == 0
          puts " #{i + 1}/#{total_photos} (#{((i + 1).to_f / total_photos * 100).round(1)}%)"
        end

      rescue Aws::S3::Errors::NotFound
        errors << "Photo #{photo.id}: S3 file not found (#{refile_id})"
        stats[:photos_skipped] += 1
      rescue Aws::S3::Errors::ServiceError => e
        errors << "Photo #{photo.id}: S3 error - #{e.message}"
        stats[:photos_skipped] += 1
      rescue StandardError => e
        errors << "Photo #{photo.id}: #{e.class} - #{e.message}"
        stats[:photos_skipped] += 1
      end
    end

    puts "\n[PHASE 1 COMPLETE] Photos: #{stats[:photos_attached]} new, #{stats[:photos_reused]} reused, #{stats[:photos_skipped]} skipped"

    # =======================================================================
    # PHASE 2: MIGRATE SONGS → Record.songs
    # =======================================================================
    total_songs = Song.where.not(audio_id: nil).count
    puts "\n[PHASE 2] Migrating #{total_songs} songs to Record.songs..."
    puts "-" * 70

    Song.where.not(audio_id: nil).includes(:record).find_each.with_index do |song, i|
      stats[:songs_processed] += 1

      unless song.record
        errors << "Song #{song.id}: No associated record (record_id: #{song.record_id})"
        stats[:songs_skipped] += 1
        next
      end

      refile_id = song.audio_id

      begin
        if migrated_blobs[refile_id]
          song.record.songs.attach(migrated_blobs[refile_id])
          stats[:songs_reused] += 1
        else
          s3_key = "store/#{refile_id}"
          response = s3.get_object(bucket: OLD_BUCKET, key: s3_key)
          file_data = response.body.read

          song.record.songs.attach(
            io: StringIO.new(file_data),
            filename: song.audio_filename || "audio.mp3",
            content_type: song.audio_content_type || "audio/mpeg",
            identify: false
          )

          migrated_blobs[refile_id] = song.record.songs.blobs.order(:created_at).last
          stats[:songs_attached] += 1
        end

        if (i + 1) % BATCH_LOG_INTERVAL == 0
          print "."
        end
        if (i + 1) % PROGRESS_LOG_INTERVAL == 0
          puts " #{i + 1}/#{total_songs} (#{((i + 1).to_f / total_songs * 100).round(1)}%)"
        end

      rescue Aws::S3::Errors::NotFound
        errors << "Song #{song.id}: S3 file not found (#{refile_id})"
        stats[:songs_skipped] += 1
      rescue Aws::S3::Errors::ServiceError => e
        errors << "Song #{song.id}: S3 error - #{e.message}"
        stats[:songs_skipped] += 1
      rescue StandardError => e
        errors << "Song #{song.id}: #{e.class} - #{e.message}"
        stats[:songs_skipped] += 1
      end
    end

    puts "\n[PHASE 2 COMPLETE] Songs: #{stats[:songs_attached]} new, #{stats[:songs_reused]} reused, #{stats[:songs_skipped]} skipped"

    # =======================================================================
    # SUMMARY
    # =======================================================================
    puts "\n"
    puts "=" * 70
    puts "MIGRATION COMPLETE"
    puts "=" * 70
    puts "Finished at: #{Time.current}"
    puts ""
    puts "RESULTS:"
    puts "  Unique blobs created:    #{migrated_blobs.size}"
    puts "  Total AS blobs:          #{ActiveStorage::Blob.count}"
    puts "  Total AS attachments:    #{ActiveStorage::Attachment.count}"
    puts "    - images:              #{ActiveStorage::Attachment.where(name: 'images').count}"
    puts "    - songs:               #{ActiveStorage::Attachment.where(name: 'songs').count}"
    puts ""
    puts "PHOTOS:"
    puts "  Processed:               #{stats[:photos_processed]}"
    puts "  New uploads:             #{stats[:photos_attached]}"
    puts "  Blob reused:             #{stats[:photos_reused]}"
    puts "  Skipped/Errors:          #{stats[:photos_skipped]}"
    puts ""
    puts "SONGS:"
    puts "  Processed:               #{stats[:songs_processed]}"
    puts "  New uploads:             #{stats[:songs_attached]}"
    puts "  Blob reused:             #{stats[:songs_reused]}"
    puts "  Skipped/Errors:          #{stats[:songs_skipped]}"
    puts ""
    puts "ERRORS: #{errors.size}"

    if errors.any?
      error_log = "/tmp/migration_errors_#{Time.current.strftime('%Y%m%d_%H%M%S')}.log"
      File.write(error_log, errors.join("\n"))
      puts "  First 10 errors:"
      errors.first(10).each { |e| puts "    - #{e}" }
      puts "  Full error log: #{error_log}"
    end

    puts "=" * 70

    # =======================================================================
    # VERIFICATION
    # =======================================================================
    puts "\nVERIFICATION:"
    puts "  Expected blobs:          39,461"
    puts "  Actual blobs:            #{ActiveStorage::Blob.count}"
    puts "  Expected image attach:   65,134"
    puts "  Actual image attach:     #{ActiveStorage::Attachment.where(name: 'images').count}"
    puts "  Expected song attach:    13,790"
    puts "  Actual song attach:      #{ActiveStorage::Attachment.where(name: 'songs').count}"

    blob_diff = ActiveStorage::Blob.count - 39_461
    image_diff = ActiveStorage::Attachment.where(name: "images").count - 65_134
    song_diff = ActiveStorage::Attachment.where(name: "songs").count - 13_790

    if blob_diff == 0 && image_diff == 0 && song_diff == 0
      puts "\n✅ ALL COUNTS MATCH EXPECTED VALUES!"
    else
      puts "\n⚠️  COUNT DIFFERENCES:"
      puts "    Blobs: #{blob_diff.positive? ? '+' : ''}#{blob_diff}"
      puts "    Images: #{image_diff.positive? ? '+' : ''}#{image_diff}"
      puts "    Songs: #{song_diff.positive? ? '+' : ''}#{song_diff}"
    end
  end

  desc "Verify Active Storage migration results"
  task verify_migration: :environment do
    puts "=" * 70
    puts "ACTIVE STORAGE MIGRATION VERIFICATION"
    puts "=" * 70

    puts "\nACTIVE STORAGE COUNTS:"
    puts "  Blobs:            #{ActiveStorage::Blob.count}"
    puts "  Image attachments: #{ActiveStorage::Attachment.where(name: 'images').count}"
    puts "  Song attachments:  #{ActiveStorage::Attachment.where(name: 'songs').count}"

    puts "\nREFILE BASELINE:"
    puts "  Photos with image_id: #{Photo.where.not(image_id: nil).count}"
    puts "  Songs with audio_id:  #{Song.where.not(audio_id: nil).count}"
    puts "  Unique image_ids:     #{Photo.where.not(image_id: nil).distinct.count(:image_id)}"
    puts "  Unique audio_ids:     #{Song.where.not(audio_id: nil).distinct.count(:audio_id)}"

    puts "\nSAMPLE VERIFICATION:"
    record = Record.joins("INNER JOIN active_storage_attachments ON active_storage_attachments.record_id = records.id AND active_storage_attachments.record_type = 'Record'").first
    if record
      puts "  Record ##{record.id}:"
      puts "    Legacy photos: #{record.photos.count}"
      puts "    AS images:     #{record.images.count}"
      puts "    Legacy songs:  #{record.songs.count}"
      puts "    AS songs:      #{record.songs_attachments.count}"

      if record.images.any?
        blob = record.images.first.blob
        puts "    Sample image URL works: #{blob.service_url rescue 'ERROR'}"
      end
    else
      puts "  No records with attachments found!"
    end

    puts "=" * 70
  end

  desc "Dry run - show what would be migrated without making changes"
  task migrate_refile_dry_run: :environment do
    require "aws-sdk-s3"

    OLD_BUCKET = "cdn.recordtemple.com"

    s3 = Aws::S3::Client.new(
      region: "us-east-1",
      credentials: Aws::Credentials.new(
        Rails.application.credentials.dig(:aws, :access_key_id),
        Rails.application.credentials.dig(:aws, :secret_access_key)
      )
    )

    puts "=" * 70
    puts "DRY RUN - Migration Preview"
    puts "=" * 70

    # Check first 5 photos
    puts "\nSample Photos (first 5):"
    Photo.where.not(image_id: nil).limit(5).each do |photo|
      s3_key = "store/#{photo.image_id}"
      begin
        head = s3.head_object(bucket: OLD_BUCKET, key: s3_key)
        puts "  Photo #{photo.id}: #{photo.image_filename} (#{(head.content_length / 1024.0).round(1)} KB) ✓"
      rescue Aws::S3::Errors::NotFound
        puts "  Photo #{photo.id}: #{photo.image_filename} - FILE MISSING ✗"
      end
    end

    # Check first 5 songs
    puts "\nSample Songs (first 5):"
    Song.where.not(audio_id: nil).limit(5).each do |song|
      s3_key = "store/#{song.audio_id}"
      begin
        head = s3.head_object(bucket: OLD_BUCKET, key: s3_key)
        puts "  Song #{song.id}: #{song.audio_filename} (#{(head.content_length / 1024.0 / 1024.0).round(2)} MB) ✓"
      rescue Aws::S3::Errors::NotFound
        puts "  Song #{song.id}: #{song.audio_filename} - FILE MISSING ✗"
      end
    end

    puts "\nTotals to migrate:"
    puts "  Photos: #{Photo.where.not(image_id: nil).count}"
    puts "  Songs:  #{Song.where.not(audio_id: nil).count}"
    puts "=" * 70
  end
end
