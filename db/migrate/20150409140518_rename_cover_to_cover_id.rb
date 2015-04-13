class RenameCoverToCoverId < ActiveRecord::Migration
  def change
    rename_column :pages, :cover, :cover_id
  end
end
