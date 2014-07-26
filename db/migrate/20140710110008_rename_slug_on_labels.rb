class RenameSlugOnLabels < ActiveRecord::Migration
  def change
    rename_column :labels, :cached_slug, :slug
  end
end
