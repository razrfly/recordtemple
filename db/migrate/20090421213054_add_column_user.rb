class AddColumnUser < ActiveRecord::Migration
  def self.up
    add_column :records, :user, :string
  end

  def self.down
    drop_column :records, :user
  end
end
