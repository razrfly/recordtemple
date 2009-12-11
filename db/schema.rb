# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091211203242) do

  create_table "bubbles", :force => true do |t|
    t.integer  "low"
    t.integer  "high"
    t.integer  "price_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "photos", :force => true do |t|
    t.integer  "record_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
  end

  create_table "prices", :force => true do |t|
    t.string   "artist"
    t.string   "format"
    t.string   "label"
    t.string   "detail"
    t.integer  "pricelow"
    t.integer  "pricehigh"
    t.integer  "yearbegin"
    t.integer  "yearend"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "footnote"
    t.string   "created_by"
  end

  create_table "records", :force => true do |t|
    t.integer  "genre"
    t.integer  "value"
    t.text     "comment"
    t.integer  "quantity"
    t.integer  "price_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "condition"
    t.string   "username"
  end

  create_table "searches", :force => true do |t|
    t.string   "artist"
    t.string   "label"
    t.string   "title"
    t.string   "format"
    t.integer  "genre"
    t.float    "minimum_value"
    t.float    "maximum_value"
    t.integer  "condition"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "page"
  end

  create_table "songs", :force => true do |t|
    t.integer  "record_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mp3_file_name"
    t.string   "mp3_content_type"
    t.integer  "mp3_file_size"
    t.datetime "mp3_updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
