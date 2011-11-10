class RemoveCreatedBy < ActiveRecord::Migration
  def self.up
    remove_column :prices, :created_by
  end

  def self.down
    add_column :prices, :created_by, :string
  end
end
