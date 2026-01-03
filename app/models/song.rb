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
  include S3Attachment

  belongs_to :record

  s3_attachment(
    id_field: :audio_id,
    filename_field: :audio_filename,
    content_type_field: :audio_content_type,
    default_content_type: "audio/mpeg",
    default_filename: "audio.mp3"
  )

  private

  def url_helper_method
    Rails.application.routes.url_helpers.song_file_path(id)
  end
end
