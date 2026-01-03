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
class Photo < ApplicationRecord
  include S3Attachment

  belongs_to :record

  s3_attachment(
    id_field: :image_id,
    filename_field: :image_filename,
    content_type_field: :image_content_type,
    default_content_type: "image/jpeg",
    default_filename: "image.jpg"
  )

  private

  def url_helper_method
    Rails.application.routes.url_helpers.photo_file_path(id)
  end
end
