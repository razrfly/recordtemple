class RenameSlugOnArtists < ActiveRecord::Migration
  def change
    rename_column :artists, :cached_slug, :slug
  end
end
