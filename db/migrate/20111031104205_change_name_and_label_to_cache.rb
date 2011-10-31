class ChangeNameAndLabelToCache < ActiveRecord::Migration
  def self.up
    rename_column :prices, :name, :cache_artist
    rename_column :prices, :label, :cache_label
  end

  def self.down
    rename_column :prices, :cache_label, :label
    rename_column :prices, :cache_artist
  end
end