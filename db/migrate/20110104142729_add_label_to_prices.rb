class AddLabelToPrices < ActiveRecord::Migration
  def self.up
    add_column :prices, :label_id, :integer
  end

  def self.down
    remove_column :prices, :label_id
  end
end
