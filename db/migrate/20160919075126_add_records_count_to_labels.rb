class AddRecordsCountToLabels < ActiveRecord::Migration
  def change
    add_column :labels, :records_count, :integer
  end
end
