class AddDiscogsToRecords < ActiveRecord::Migration[8.1]
  def change
    add_reference :records, :discogs_release, foreign_key: true, index: true

    # Match quality (specific to this record's match)
    add_column :records, :discogs_confidence, :decimal, precision: 5, scale: 2
    add_column :records, :discogs_match_method, :string
    add_column :records, :discogs_matched_at, :datetime

    add_index :records, :discogs_confidence
  end
end
