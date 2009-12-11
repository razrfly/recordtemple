class CreateBubbles < ActiveRecord::Migration
  def self.up
    create_table :bubbles do |t|
      t.integer :low
      t.integer :high
      t.integer :price_id

      t.timestamps
    end
  end

  def self.down
    drop_table :bubbles
  end
end
