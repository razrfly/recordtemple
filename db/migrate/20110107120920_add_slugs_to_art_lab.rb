class AddSlugsToArtLab < ActiveRecord::Migration
  def self.up
    add_column :artists, :cached_slug, :string
    add_column :labels, :cached_slug, :string
    add_index  :artists, :cached_slug, :unique => true
    add_index  :labels, :cached_slug, :unique => true
  end

  def self.down
    remove_column :artists, :cached_slug
    remove_column :labels, :cached_slug
  end
end
