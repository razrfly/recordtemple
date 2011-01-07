# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110107100423) do

  create_table "artists", :force => true do |t|
    t.string   "name"
    t.string   "freebase_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "artists", ["name"], :name => "index_artists_on_name", :unique => true

  create_table "bubbles", :force => true do |t|
    t.integer  "low"
    t.integer  "high"
    t.integer  "price_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "genres", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "labels", :force => true do |t|
    t.string   "name"
    t.string   "freebase_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "labels", ["name"], :name => "index_labels_on_name", :unique => true

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
    t.integer  "artist_id"
    t.integer  "label_id"
  end

  create_table "recommendations", :force => true do |t|
    t.string   "email"
    t.text     "message"
    t.string   "token"
    t.date     "expiration"
    t.integer  "record_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "records", :force => true do |t|
    t.integer  "genre_id"
    t.integer  "value"
    t.text     "comment"
    t.integer  "quantity"
    t.integer  "price_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "condition"
    t.integer  "user_id"
    t.integer  "artist_id"
    t.integer  "label_id"
    t.integer  "identifier_id"
  end

  create_table "songs", :force => true do |t|
    t.integer  "record_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mp3_file_name"
    t.string   "mp3_content_type"
    t.integer  "mp3_file_size"
    t.datetime "mp3_updated_at"
    t.string   "title"
    t.string   "panda_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nickname"
    t.string   "fname"
    t.string   "lname"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
