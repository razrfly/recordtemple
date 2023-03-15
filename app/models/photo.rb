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
  belongs_to :record
end
