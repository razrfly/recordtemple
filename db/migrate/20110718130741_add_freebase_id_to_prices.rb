class AddFreebaseIdToPrices < ActiveRecord::Migration
  def self.up
    add_column :prices, :freebase_id, :string
  end

  def self.down
    remove_column :prices, :freebase_id
  end
end
