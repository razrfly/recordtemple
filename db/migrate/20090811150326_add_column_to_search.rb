class AddColumnToSearch < ActiveRecord::Migration
  def self.up
    add_column :searches, :page, :integer
  end

  def self.down
    remove_column :searches, :page
  end
end
