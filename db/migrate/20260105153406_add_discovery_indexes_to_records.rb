class AddDiscoveryIndexesToRecords < ActiveRecord::Migration[8.1]
  def change
    # Optimize discovery scopes that filter by user and group by artist/label/genre
    add_index :records, [:user_id, :artist_id], name: "index_records_on_user_and_artist"
    add_index :records, [:user_id, :label_id], name: "index_records_on_user_and_label"
    add_index :records, [:user_id, :genre_id], name: "index_records_on_user_and_genre"

    # Optimize recently_added scope that orders by created_at within user
    add_index :records, [:user_id, :created_at], name: "index_records_on_user_and_created_at"
  end
end
