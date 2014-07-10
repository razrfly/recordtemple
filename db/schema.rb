# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140710110008) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: true do |t|
    t.integer  "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_admin_notes_on_resource_type_and_resource_id", using: :btree

  create_table "artists", force: true do |t|
    t.string   "name"
    t.string   "freebase_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "artists", ["name"], name: "index_artists_on_name", unique: true, using: :btree
  add_index "artists", ["slug"], name: "index_artists_on_slug", unique: true, using: :btree

  create_table "bubbles", force: true do |t|
    t.integer  "low"
    t.integer  "high"
    t.integer  "price_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bubbles", ["price_id"], name: "index_bubbles_on_price_id", using: :btree

  create_table "genres", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cached_slug"
  end

  add_index "genres", ["cached_slug"], name: "index_genres_on_cached_slug", unique: true, using: :btree

  create_table "labels", force: true do |t|
    t.string   "name"
    t.string   "freebase_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "labels", ["name"], name: "index_labels_on_name", unique: true, using: :btree
  add_index "labels", ["slug"], name: "index_labels_on_slug", unique: true, using: :btree

  create_table "photos", force: true do |t|
    t.integer  "record_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
    t.integer  "position"
    t.string   "title"
    t.text     "data_meta"
  end

  add_index "photos", ["record_id"], name: "index_photos_on_record_id", using: :btree

  create_table "prices", force: true do |t|
    t.string   "cached_artist"
    t.string   "media_type"
    t.string   "cached_label"
    t.string   "detail"
    t.integer  "pricelow"
    t.integer  "pricehigh"
    t.integer  "yearbegin"
    t.integer  "yearend"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "footnote"
    t.integer  "artist_id"
    t.integer  "label_id"
    t.integer  "record_format_id"
    t.string   "freebase_id"
    t.integer  "user_id"
  end

  create_table "recommendations", force: true do |t|
    t.string   "email"
    t.text     "message"
    t.string   "token"
    t.date     "expiration"
    t.integer  "record_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "record_formats", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "record_type_id"
  end

  create_table "record_listings", force: true do |t|
    t.integer  "record_id"
    t.string   "external_id"
    t.string   "listing_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "record_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "records", force: true do |t|
    t.integer  "genre_id"
    t.integer  "value"
    t.text     "comment"
    t.integer  "price_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "condition"
    t.integer  "user_id"
    t.integer  "identifier_id"
    t.string   "cached_artist"
    t.string   "cached_label"
  end

  add_index "records", ["genre_id"], name: "index_records_on_genre_id", using: :btree
  add_index "records", ["price_id"], name: "index_records_on_price_id", using: :btree
  add_index "records", ["user_id"], name: "index_records_on_user_id", using: :btree

  create_table "slugs", force: true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                  default: 1, null: false
    t.string   "sluggable_type", limit: 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], name: "index_slugs_on_n_s_s_and_s", unique: true, using: :btree
  add_index "slugs", ["sluggable_id"], name: "index_slugs_on_sluggable_id", using: :btree

  create_table "songs", force: true do |t|
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

  add_index "songs", ["record_id"], name: "index_songs_on_record_id", using: :btree

  create_table "user_accounts", force: true do |t|
    t.string   "provider"
    t.string   "auth_type"
    t.string   "key"
    t.string   "secret"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                            default: "", null: false
    t.string   "encrypted_password",   limit: 128, default: "", null: false
    t.string   "password_salt",                    default: "", null: false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    default: 0
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
    t.string   "unconfirmed_email"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
