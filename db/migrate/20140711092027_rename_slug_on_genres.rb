class RenameSlugOnGenres < ActiveRecord::Migration
  def change
    rename_column :genres, :cached_slug, :slug
  end
end
