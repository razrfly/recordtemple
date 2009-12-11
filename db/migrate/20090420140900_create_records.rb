class CreateRecords < ActiveRecord::Migration
  def self.up
    create_table :records do |t|
      t.string :genre
      t.integer :value
      t.text :comment
      t.integer :quantity
      t.integer :price_id

      t.timestamps
    end
  end

  def self.down
    drop_table :records
  end
end
