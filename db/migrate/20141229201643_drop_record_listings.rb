class DropRecordListings < ActiveRecord::Migration
  def up
    drop_table :record_listings
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
