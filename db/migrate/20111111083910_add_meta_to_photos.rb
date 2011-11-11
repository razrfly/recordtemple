class AddMetaToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :data_meta, :text
  end

  def self.down
    remove_column :photos, :data_meta
  end
end
