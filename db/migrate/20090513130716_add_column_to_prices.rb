class AddColumnToPrices < ActiveRecord::Migration
  def self.up
    add_column :prices, :created_by, :string
  end

  def self.down
    remove_column :prices, :created_by
  end
end
