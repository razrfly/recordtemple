# == Schema Information
#
# Table name: songs
#
#  id                 :integer          not null, primary key
#  audio_content_type :string(255)
#  audio_filename     :string(255)
#  audio_size         :integer
#  mp3_content_type   :string(255)
#  mp3_file_name      :string(255)
#  mp3_file_size      :integer
#  mp3_updated_at     :datetime
#  title              :string(255)
#  url                :string
#  created_at         :datetime
#  updated_at         :datetime
#  audio_id           :string(255)
#  panda_id           :string(255)
#  record_id          :integer
#
# Indexes
#
#  index_songs_on_record_id  (record_id)
#
require "aws-sdk-s3"

class Song < ApplicationRecord
  belongs_to :record

  BUCKET = "cdn.recordtemple.com".freeze
  REGION = "us-east-1".freeze

  # Generate URL for accessing the audio
  # Returns a Rails route that proxies to S3
  def url
    return nil unless audio_id.present?
    Rails.application.routes.url_helpers.song_file_path(id)
  end

  # Get raw file data from S3
  def file_data
    return nil unless audio_id.present?
    s3_client.get_object(bucket: BUCKET, key: s3_key).body.read
  end

  def s3_key
    "store/#{audio_id}"
  end

  def content_type
    audio_content_type || "audio/mpeg"
  end

  def filename
    audio_filename || "audio.mp3"
  end

  def exists_in_s3?
    return false unless audio_id.present?
    s3_client.head_object(bucket: BUCKET, key: s3_key)
    true
  rescue Aws::S3::Errors::NotFound
    false
  end

  private

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
