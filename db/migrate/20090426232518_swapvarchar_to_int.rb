class SwapvarcharToInt < ActiveRecord::Migration
  def self.up
    change_column :records, :genre, :integer
  end

  def self.down
    change_column :records, :genre, :string
  end
end
