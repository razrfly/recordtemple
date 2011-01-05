class CreateSearches < ActiveRecord::Migration
  def self.up
    create_table :searches do |t|
      t.string :artist
      t.string :label
      t.string :title
      t.string :format
      t.integer :genre
      t.float :minimum_value
      t.float :maximum_value
      t.integer :condition
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :searches
  end
end
