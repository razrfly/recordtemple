# == Schema Information
#
# Table name: photos
#
#  id                 :integer          not null, primary key
#  data_content_type  :string(255)
#  data_file_name     :string(255)
#  data_file_size     :integer
#  data_meta          :text
#  data_updated_at    :datetime
#  image_content_type :string(255)
#  image_filename     :string(255)
#  image_size         :integer
#  position           :integer
#  title              :string(255)
#  url                :string
#  created_at         :datetime
#  updated_at         :datetime
#  image_id           :string(255)
#  record_id          :integer
#
# Indexes
#
#  index_photos_on_record_id  (record_id)
#
require "aws-sdk-s3"

class Photo < ApplicationRecord
  belongs_to :record

  BUCKET = "cdn.recordtemple.com".freeze
  REGION = "us-east-1".freeze

  # Generate URL for accessing the image
  # Returns a Rails route that proxies to S3
  def url
    return nil unless image_id.present?
    Rails.application.routes.url_helpers.photo_file_path(id)
  end

  # Get raw file data from S3
  def file_data
    return nil unless image_id.present?
    s3_client.get_object(bucket: BUCKET, key: s3_key).body.read
  end

  def s3_key
    "store/#{image_id}"
  end

  def content_type
    image_content_type || "image/jpeg"
  end

  def filename
    image_filename || "image.jpg"
  end

  def exists_in_s3?
    return false unless image_id.present?
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
