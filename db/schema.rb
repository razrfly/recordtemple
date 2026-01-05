# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_04_233359) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "artists", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "name", limit: 255
    t.string "slug", limit: 255
    t.datetime "updated_at", precision: nil
    t.index "to_tsvector('english'::regconfig, (COALESCE(name, ''::character varying))::text)", name: "artists_fts_idx", using: :gin
    t.index ["name"], name: "index_artists_on_name", unique: true
    t.index ["slug"], name: "index_artists_on_slug", unique: true
  end

  create_table "genres", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "name", limit: 255
    t.string "slug", limit: 255
    t.datetime "updated_at", precision: nil
    t.index ["slug"], name: "index_genres_on_slug", unique: true
  end

  create_table "labels", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "name", limit: 255
    t.string "slug", limit: 255
    t.datetime "updated_at", precision: nil
    t.index "to_tsvector('english'::regconfig, (COALESCE(name, ''::character varying))::text)", name: "labels_fts_idx", using: :gin
    t.index ["name"], name: "index_labels_on_name", unique: true
    t.index ["slug"], name: "index_labels_on_slug", unique: true
  end

  create_table "passwordless_sessions", force: :cascade do |t|
    t.bigint "authenticatable_id"
    t.string "authenticatable_type"
    t.datetime "claimed_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "expires_at", precision: nil, null: false
    t.string "identifier"
    t.string "remote_addr"
    t.datetime "timeout_at", precision: nil, null: false
    t.string "token", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "user_agent"
    t.index ["authenticatable_type", "authenticatable_id"], name: "authenticatable"
    t.index ["identifier"], name: "index_passwordless_sessions_on_identifier", unique: true
  end

  create_table "photos", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "data_content_type", limit: 255
    t.string "data_file_name", limit: 255
    t.integer "data_file_size"
    t.text "data_meta"
    t.datetime "data_updated_at", precision: nil
    t.string "image_content_type", limit: 255
    t.string "image_filename", limit: 255
    t.string "image_id", limit: 255
    t.integer "image_size"
    t.integer "position"
    t.integer "record_id"
    t.string "title", limit: 255
    t.datetime "updated_at", precision: nil
    t.string "url"
    t.index ["record_id"], name: "index_photos_on_record_id"
  end

  create_table "prices", id: :serial, force: :cascade do |t|
    t.integer "artist_id"
    t.string "cached_artist", limit: 255
    t.string "cached_label", limit: 255
    t.datetime "created_at", precision: nil
    t.string "detail", limit: 255
    t.text "footnote"
    t.integer "label_id"
    t.string "media_type", limit: 255
    t.integer "price_high"
    t.integer "price_low"
    t.integer "record_format_id"
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.integer "yearbegin"
    t.integer "yearend"
    t.index ["cached_artist"], name: "index_prices_on_cached_artist_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["cached_label"], name: "index_prices_on_cached_label_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["detail"], name: "index_prices_on_detail_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["media_type"], name: "index_prices_on_media_type_trigram", opclass: :gin_trgm_ops, using: :gin
  end

  create_table "record_formats", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "name", limit: 255
    t.integer "record_type_id"
    t.datetime "updated_at", precision: nil
  end

  create_table "record_types", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "name", limit: 255
    t.datetime "updated_at", precision: nil
  end

  create_table "records", id: :serial, force: :cascade do |t|
    t.integer "artist_id"
    t.string "cached_artist", limit: 255
    t.string "cached_label", limit: 255
    t.text "comment"
    t.integer "condition"
    t.datetime "created_at", precision: nil
    t.integer "genre_id"
    t.integer "identifier_id"
    t.integer "label_id"
    t.integer "price_id"
    t.integer "record_format_id"
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.integer "value"
    t.index "to_tsvector('english'::regconfig, COALESCE(comment, ''::text))", name: "records_fts_idx", using: :gin
    t.index ["artist_id"], name: "index_records_on_artist_id"
    t.index ["genre_id"], name: "index_records_on_genre_id"
    t.index ["label_id"], name: "index_records_on_label_id"
    t.index ["price_id"], name: "index_records_on_price_id"
    t.index ["record_format_id"], name: "index_records_on_record_format_id"
    t.index ["user_id"], name: "index_records_on_user_id"
  end

  create_table "songs", id: :serial, force: :cascade do |t|
    t.string "audio_content_type", limit: 255
    t.string "audio_filename", limit: 255
    t.string "audio_id", limit: 255
    t.integer "audio_size"
    t.datetime "created_at", precision: nil
    t.string "mp3_content_type", limit: 255
    t.string "mp3_file_name", limit: 255
    t.integer "mp3_file_size"
    t.datetime "mp3_updated_at", precision: nil
    t.string "panda_id", limit: 255
    t.integer "record_id"
    t.string "title", limit: 255
    t.datetime "updated_at", precision: nil
    t.string "url"
    t.index ["record_id"], name: "index_songs_on_record_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "email", limit: 255, default: "", null: false
    t.datetime "updated_at", precision: nil
    t.string "username", limit: 255
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "prices", "artists"
  add_foreign_key "prices", "labels"
  add_foreign_key "prices", "record_formats"
  add_foreign_key "prices", "users"
  add_foreign_key "record_formats", "record_types"
  add_foreign_key "records", "artists"
  add_foreign_key "records", "genres"
  add_foreign_key "records", "labels"
  add_foreign_key "records", "prices"
  add_foreign_key "records", "record_formats"
  add_foreign_key "records", "users"
end
