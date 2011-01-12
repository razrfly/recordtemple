class AddPositionToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :position, :integer
    add_column :photos, :title, :string
  end

  def self.down
    remove_column :photos, :title
    remove_column :photos, :position
  end
end
