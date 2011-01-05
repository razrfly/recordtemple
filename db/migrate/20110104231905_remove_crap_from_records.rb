class RemoveCrapFromRecords < ActiveRecord::Migration
  def self.up
    remove_column :records, :username
  end

  def self.down
    add_column :records, :username
  end
end
