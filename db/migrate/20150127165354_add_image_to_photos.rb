class AddImageToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :image_id, :string
  end
end
