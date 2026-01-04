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
# Note: Legacy Refile columns (audio_id, audio_filename, etc.) are preserved
# as backup but no longer used. Files are served via Active Storage.
#
class Song < ApplicationRecord
  belongs_to :record

  # Find the corresponding Active Storage attachment on the parent Record
  # Matches by filename since that's how files were migrated from Refile
  # Note: record.songs is Active Storage (has_many_attached), not Song models
  def active_storage_attachment
    return nil unless record&.songs_attachments&.any?

    record.songs.find { |s| s.filename.to_s == audio_filename }
  end

  # URL for serving this song (backwards compatible route)
  def url
    Rails.application.routes.url_helpers.song_file_path(id)
  end

  # Delegate to Active Storage blob for content type
  def content_type
    active_storage_attachment&.content_type || audio_content_type || "audio/mpeg"
  end

  # Delegate to Active Storage blob for filename
  def filename
    active_storage_attachment&.filename&.to_s || audio_filename || "audio.mp3"
  end
end
