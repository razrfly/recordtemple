class CreatePrices < ActiveRecord::Migration
  def self.up
    create_table :prices do |t|
      t.string :artist
      t.string :format
      t.string :label
      t.string :detail
      t.integer :pricelow
      t.integer :pricehigh
      t.integer :yearbegin
      t.integer :yearend

      t.timestamps
    end
  end

  def self.down
    drop_table :prices
  end
end
