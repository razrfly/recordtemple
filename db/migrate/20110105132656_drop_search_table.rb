class DropSearchTable < ActiveRecord::Migration
  def self.up
    drop_table :searches
  end

  def self.down
  end
end
