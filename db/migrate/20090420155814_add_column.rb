class AddColumn < ActiveRecord::Migration
  def self.up
    add_column :records, :condition, :integer
  end

  def self.down
    drop_column :records, :condition
  end
end
