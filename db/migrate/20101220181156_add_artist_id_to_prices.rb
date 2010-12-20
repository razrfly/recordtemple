class AddArtistIdToPrices < ActiveRecord::Migration
  def self.up
    add_column :prices, :artist_id, :integer
  end

  def self.down
    remove_column :prices, :artist_id
  end
end
