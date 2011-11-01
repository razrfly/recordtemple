class LotOIndexes < ActiveRecord::Migration
  def self.up
    #add_index :records, [:artist_id, :genre_id, :label_id, :price_id, :user_id]
    #add_index :price, [:record_format_id, :artist_id, :label_id]
    
    add_index :records, :artist_id
    add_index :records, :genre_id
    add_index :records, :label_id
    add_index :records, :price_id
    add_index :records, :user_id
    
    add_index :bubbles, :price_id
    add_index :photos, :record_id
    add_index :songs, :record_id
  end

  def self.down
    remove_index :records, :user_id
    remove_index :records, :price_id
    remove_index :records, :label_id
    remove_index :records, :genre_id
    remove_index :records, :artist_id
    
    remove_index :bubbles, :price_id
    remove_index :photos, :record_id
    remove_index :songs, :record_id
    #remove_index :table_name, :column_name
  end
end