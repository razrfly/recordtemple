class DropTableMugshots < ActiveRecord::Migration
  def self.up
    drop_table :mugshots
  end

  def self.down
    create_table "mugshots", :force => true do |t|
      t.integer  "record_id"
      t.integer  "parent_id"
      t.string   "content_type"
      t.string   "filename"
      t.string   "thumbnail"
      t.integer  "size"
      t.integer  "width"
      t.integer  "height"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
  end
end
