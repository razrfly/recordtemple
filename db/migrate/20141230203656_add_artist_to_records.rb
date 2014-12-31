class AddArtistToRecords < ActiveRecord::Migration
  def up
    add_reference :records, :artist, :index => true
    execute %q{UPDATE records SET artist_id = (SELECT prices.artist_id FROM prices WHERE prices.id = records.price_id)}
  end

  def down
    remove_reference :records, :artist, :index => true
  end
end
