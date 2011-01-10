class RenamePriceThing < ActiveRecord::Migration
  def self.up
    rename_column :prices, :artist, :name
  end

  def self.down
    rename_column :prices, :name, :artist
  end
end
