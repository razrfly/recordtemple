class AddMetadataColumnsToMedia < ActiveRecord::Migration
  def change
    add_column :photos, :image_filename, :string
    add_column :photos, :image_size, :integer

    add_column :songs, :audio_filename, :string
    add_column :songs, :audio_size, :integer
  end
end
