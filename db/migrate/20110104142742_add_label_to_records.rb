class AddLabelToRecords < ActiveRecord::Migration
  def self.up
    add_column :records, :label_id, :integer
  end

  def self.down
    remove_column :records, :label_id
  end
end
