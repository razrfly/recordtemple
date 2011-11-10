class FixCachedTitles < ActiveRecord::Migration
  def self.up
    rename_column :prices, :cache_artist, :cached_artist
    rename_column :prices, :cache_label, :cached_label
  end

  def self.down
    rename_column :prices, :cached_label
    rename_column :prices, :cached_artist, :cache_artist
  end
end