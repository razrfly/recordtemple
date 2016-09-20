class AddRecordsCountToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :records_count, :integer
  end
end
