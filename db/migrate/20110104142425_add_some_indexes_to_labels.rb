class AddSomeIndexesToLabels < ActiveRecord::Migration
  def self.up
    add_index :labels, :name, :unique => true
    add_index :artists, :name, :unique => true
  end

  def self.down
    remove_index :labels, :name, :unique => true
    remove_index :artists, :name, :unique => true
  end
end
