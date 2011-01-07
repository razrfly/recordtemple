class AddColumnCacheArtistsToRecords < ActiveRecord::Migration
  def self.up
    add_column :records, :cached_artist, :string
    #Record.all.each do |r|
    #  r.update_attribute :cached_artist, r.artist.name
    #end
  end

  def self.down
    remove_column :records, :cached_artist
  end
end
