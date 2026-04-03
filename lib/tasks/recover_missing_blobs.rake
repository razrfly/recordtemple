namespace :storage do
  desc "Audit ActiveStorage blobs migrated from Refile that are missing from S3 (dry run)"
  task audit_missing_blobs: :environment do
    blobs_with_refile_id = ActiveStorage::Blob.where("metadata->>'refile_id' IS NOT NULL")
    total = blobs_with_refile_id.count
    puts "Checking #{total} blobs with refile_id metadata..."

    missing_count = 0
    missing_sample = []
    checked = 0

    blobs_with_refile_id.find_each(batch_size: 100) do |blob|
      unless ActiveStorage::Blob.service.exist?(blob.key)
        missing_count += 1
        missing_sample << blob if missing_sample.size < 10
      end
      checked += 1
      print "." if (checked % 100).zero?
    end

    puts "" if total > 0
    puts "\n=== Audit Results ==="
    puts "Total checked:    #{checked}"
    puts "Missing:          #{missing_count}"
    puts "Already present:  #{checked - missing_count}"
    puts "Missing %:        #{checked > 0 ? (missing_count.to_f / checked * 100).round(2) : 0}%"

    if missing_sample.any?
      puts "\nSample missing filenames (up to 10):"
      missing_sample.each do |blob|
        puts "  blob##{blob.id} key=#{blob.key} refile_id=#{blob.metadata['refile_id']} filename=#{blob.filename}"
      end
    end
  end

  desc "Recover missing S3 blobs by copying from old Refile bucket (idempotent)"
  task recover_missing_blobs: :environment do
    require "aws-sdk-s3"
    require "cgi"

    old_bucket = "cdn.recordtemple.com"
    new_bucket = "cdn4.recordtemple.com"
    region     = "us-east-1"

    access_key_id     = Rails.application.credentials.dig(:aws, :access_key_id)
    secret_access_key = Rails.application.credentials.dig(:aws, :secret_access_key)
    abort "ERROR: AWS credentials missing from Rails credentials (aws.access_key_id / aws.secret_access_key)" if access_key_id.blank? || secret_access_key.blank?

    s3_client = Aws::S3::Client.new(
      region: region,
      access_key_id: access_key_id,
      secret_access_key: secret_access_key
    )

    blobs_with_refile_id = ActiveStorage::Blob.where("metadata->>'refile_id' IS NOT NULL")
    total = blobs_with_refile_id.count
    puts "Processing #{total} blobs with refile_id metadata..."

    recovered = 0
    already_present = 0
    not_in_old_bucket = 0
    errors = 0
    processed = 0

    blobs_with_refile_id.find_each(batch_size: 100) do |blob|
      refile_id = blob.metadata["refile_id"]
      old_key = "store/#{refile_id}"

      begin
        if ActiveStorage::Blob.service.exist?(blob.key)
          already_present += 1
        else
          content_type = blob.content_type.presence || "application/octet-stream"
          encoded_old_key = old_key.split("/").map { |seg| CGI.escape(seg) }.join("/")
          s3_client.copy_object(
            copy_source: "#{old_bucket}/#{encoded_old_key}",
            bucket: new_bucket,
            key: blob.key,
            content_type: content_type,
            cache_control: "public, max-age=31536000",
            metadata_directive: "REPLACE"
          )
          recovered += 1
        end
      rescue Aws::S3::Errors::NoSuchKey
        puts "  NOT FOUND in old bucket: blob##{blob.id} refile_id=#{refile_id} filename=#{blob.filename}"
        not_in_old_bucket += 1
      rescue => e
        puts "  ERROR blob##{blob.id} refile_id=#{refile_id}: #{e.class}: #{e.message}"
        errors += 1
      end

      processed += 1
      if (processed % 100).zero?
        puts "Progress: #{processed}/#{total} — recovered=#{recovered} skipped=#{already_present} missing_source=#{not_in_old_bucket} errors=#{errors}"
      end
    end

    puts "\n=== Recovery Complete ==="
    puts "Total processed:     #{processed}"
    puts "Recovered:           #{recovered}"
    puts "Already present:     #{already_present}"
    puts "Not in old bucket:   #{not_in_old_bucket}"
    puts "Errors:              #{errors}"
  end
end
