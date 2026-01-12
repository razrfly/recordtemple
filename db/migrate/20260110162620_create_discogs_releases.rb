class CreateDiscogsReleases < ActiveRecord::Migration[8.1]
  def change
    create_table :discogs_releases do |t|
      # Discogs identifiers
      t.bigint :discogs_id, null: false
      t.bigint :master_id

      # Core release data
      t.string :title, null: false
      t.integer :year
      t.string :country
      t.string :catno

      # Structured data (arrays/objects)
      t.jsonb :artists, default: []
      t.jsonb :labels, default: []
      t.jsonb :formats, default: []
      t.jsonb :tracklist, default: []
      t.jsonb :genres, default: []
      t.jsonb :styles, default: []
      t.jsonb :images, default: []

      # Community/market data
      t.integer :community_have
      t.integer :community_want
      t.decimal :lowest_price, precision: 10, scale: 2

      # Full API response for future use
      t.jsonb :raw_response, default: {}

      # Metadata
      t.datetime :fetched_at, null: false

      t.timestamps
    end

    add_index :discogs_releases, :discogs_id, unique: true
    add_index :discogs_releases, :master_id
    add_index :discogs_releases, :catno
    add_index :discogs_releases, :artists, using: :gin
  end
end
