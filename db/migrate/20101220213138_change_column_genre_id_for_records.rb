class ChangeColumnGenreIdForRecords < ActiveRecord::Migration
  def self.up
    rename_column :records, :genre, :genre_id
  end

  def self.down
    rename_column :records, :genre_id, :genre
  end
end
