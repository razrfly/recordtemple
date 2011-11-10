class AddAnotherColumnToPrices < ActiveRecord::Migration
  def self.up
    add_column :prices, :user_id, :integer
  end

  def self.down
    remove_column :prices, :user_id
  end
end
