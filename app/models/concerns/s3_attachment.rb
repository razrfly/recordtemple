module S3Attachment
  extend ActiveSupport::Concern

  BUCKET = "cdn.recordtemple.com".freeze
  REGION = "us-east-1".freeze

  class_methods do
    def s3_attachment(id_field:, filename_field:, content_type_field:, default_content_type:, default_filename:)
      define_method(:attachment_id) { send(id_field) }
      define_method(:attachment_filename) { send(filename_field) }
      define_method(:attachment_content_type) { send(content_type_field) }
      define_method(:default_content_type) { default_content_type }
      define_method(:default_filename) { default_filename }
    end
  end

  # Generate URL for accessing the file
  # Returns a Rails route that proxies to S3
  def url
    return nil unless attachment_id.present?
    url_helper_method
  end

  # Get raw file data from S3
  def file_data
    return nil unless attachment_id.present?
    s3_client.get_object(bucket: BUCKET, key: s3_key).body.read
  rescue Aws::S3::Errors::NotFound, Aws::S3::Errors::NoSuchKey
    nil
  end

  def s3_key
    "store/#{attachment_id}"
  end

  def content_type
    attachment_content_type || default_content_type
  end

  def filename
    attachment_filename || default_filename
  end

  def exists_in_s3?
    return false unless attachment_id.present?
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

  # Override in including class
  def url_helper_method
    raise NotImplementedError, "Define url_helper_method in including class"
  end
end
