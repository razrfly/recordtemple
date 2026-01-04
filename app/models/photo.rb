# == Schema Information
#
# Table name: photos
#
#  id                 :integer          not null, primary key
#  record_id          :integer
#  created_at         :datetime
#  updated_at         :datetime
#  data_file_name     :string(255)
#  data_content_type  :string(255)
#  data_file_size     :integer
#  data_updated_at    :datetime
#  position           :integer
#  title              :string(255)
#  data_meta          :text
#  image_id           :string(255)
#  image_content_type :string(255)
#  image_filename     :string(255)
#  image_size         :integer
#  url                :string
#
# Indexes
#
#  index_photos_on_record_id  (record_id)
#

class Photo < ApplicationRecord
  belongs_to :record

  # Find the corresponding Active Storage attachment on the parent Record
  # Matches by filename since that's how files were migrated from Refile
  def active_storage_attachment
    return nil unless record&.images&.attached?

    record.images.find { |img| img.filename.to_s == image_filename }
  end

  # URL for serving this photo (backwards compatible route)
  def url
    Rails.application.routes.url_helpers.photo_file_path(id)
  end

  # Delegate to Active Storage blob for content type
  def content_type
    active_storage_attachment&.content_type || image_content_type || "image/jpeg"
  end

  # Delegate to Active Storage blob for filename
  def filename
    active_storage_attachment&.filename&.to_s || image_filename || "image.jpg"
  end
end
