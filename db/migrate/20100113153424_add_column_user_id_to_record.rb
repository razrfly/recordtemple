class AddColumnUserIdToRecord < ActiveRecord::Migration
  def self.up
    add_column :records, :user_id, :integer
  end

  def self.down
    remove_column :records, :user_id
  end
end
