class AddIdentifierIdToRecords < ActiveRecord::Migration
  def self.up
    add_column :records, :identifier_id, :integer
  end

  def self.down
    remove_column :records, :identifier_id
  end
end
