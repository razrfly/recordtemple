class CreateRecordListings < ActiveRecord::Migration
  def self.up

    create_table :record_listings do |t|
      t.integer :record_id
      t.string :external_id
      t.string :listing_type
      t.timestamps
    end

  end

  def self.down
    remove_index :record_listings, [:record_id, :listing_type]
    drop_table :record_listings
  end
end
