class RenameColumnRecordUser < ActiveRecord::Migration
  def self.up
    rename_column :records, :user, :username
  end

  def self.down
    rename_column :records, :username, :user
  end
end
