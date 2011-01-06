class AddStupidIdToSongs < ActiveRecord::Migration
  def self.up
    add_column :songs, :panda_id, :string
  end

  def self.down
    remove_column :songs, :panda_id
  end
end
