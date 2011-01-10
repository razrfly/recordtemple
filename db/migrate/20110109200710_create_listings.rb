class CreateListings < ActiveRecord::Migration
  def self.up
    create_table :listings do |t|
      t.integer :record_id
      t.integer :external_id
      t.string :listing_type

      t.timestamps
    end
  end

  def self.down
    drop_table :listings
  end
end
