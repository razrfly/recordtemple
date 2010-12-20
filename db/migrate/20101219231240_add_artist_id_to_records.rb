class AddArtistIdToRecords < ActiveRecord::Migration
  def self.up
    add_column :records, :artist_id, :integer
  end

  def self.down
    remove_column :records, :artist_id
  end
end
