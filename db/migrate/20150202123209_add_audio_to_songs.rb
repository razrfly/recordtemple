class AddAudioToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :audio_id, :string
  end
end
