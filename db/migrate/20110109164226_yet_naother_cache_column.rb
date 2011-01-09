class YetNaotherCacheColumn < ActiveRecord::Migration
  def self.up
    add_column :genres, :cached_slug, :string
    add_index  :genres, :cached_slug, :unique => true
  end

  def self.down
    remove_column :genres, :cached_slug
  end
end
