class AddMetadataToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :image_content_type, :string
  end

  def self.down
    remove_column :photos, :image_content_type, :string
  end
end
