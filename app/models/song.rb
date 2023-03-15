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
class Song < ApplicationRecord
  belongs_to :record

end
