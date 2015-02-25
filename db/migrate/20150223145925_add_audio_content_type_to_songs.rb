class AddAudioContentTypeToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :audio_content_type, :string
  end
end
