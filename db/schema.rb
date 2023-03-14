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

ActiveRecord::Schema[7.0].define(version: 2023_03_12_175832) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "active_admin_comments", id: :integer, default: -> { "nextval('admin_notes_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "resource_id", null: false
    t.string "resource_type", limit: 255, null: false
    t.integer "author_id"
    t.string "author_type", limit: 255
    t.text "body"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "namespace", limit: 255
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_admin_notes_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "artists", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "freebase_id", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "slug", limit: 255
    t.index "to_tsvector('english'::regconfig, (COALESCE(name, ''::character varying))::text)", name: "artists_fts_idx", using: :gin
    t.index ["name"], name: "index_artists_on_name", unique: true
    t.index ["slug"], name: "index_artists_on_slug", unique: true
  end

  create_table "blazer_audits", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "query_id"
    t.text "statement"
    t.string "data_source", limit: 255
    t.datetime "created_at", precision: nil
  end

  create_table "blazer_checks", id: :serial, force: :cascade do |t|
    t.integer "query_id"
    t.string "state", limit: 255
    t.text "emails"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "creator_id"
    t.boolean "invert"
    t.string "schedule", limit: 255
    t.datetime "last_run_at", precision: nil
    t.string "check_type", limit: 255
    t.text "message"
  end

  create_table "blazer_dashboard_queries", id: :serial, force: :cascade do |t|
    t.integer "dashboard_id"
    t.integer "query_id"
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "blazer_dashboards", id: :serial, force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "creator_id"
  end

  create_table "blazer_queries", id: :serial, force: :cascade do |t|
    t.integer "creator_id"
    t.string "name", limit: 255
    t.text "description"
    t.text "statement"
    t.string "data_source", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "genres", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "slug", limit: 255
    t.index ["slug"], name: "index_genres_on_slug", unique: true
  end

  create_table "labels", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "freebase_id", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "slug", limit: 255
    t.index "to_tsvector('english'::regconfig, (COALESCE(name, ''::character varying))::text)", name: "labels_fts_idx", using: :gin
    t.index ["name"], name: "index_labels_on_name", unique: true
    t.index ["slug"], name: "index_labels_on_slug", unique: true
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.text "content"
    t.integer "user_id"
    t.integer "position"
    t.string "cover_id", limit: 255
    t.string "slug", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["user_id"], name: "index_pages_on_user_id"
  end

  create_table "passwordless_sessions", force: :cascade do |t|
    t.string "authenticatable_type"
    t.bigint "authenticatable_id"
    t.datetime "timeout_at", precision: nil, null: false
    t.datetime "expires_at", precision: nil, null: false
    t.datetime "claimed_at", precision: nil
    t.text "user_agent", null: false
    t.string "remote_addr", null: false
    t.string "token", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["authenticatable_type", "authenticatable_id"], name: "authenticatable"
  end

  create_table "photos", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "data_file_name", limit: 255
    t.string "data_content_type", limit: 255
    t.integer "data_file_size"
    t.datetime "data_updated_at", precision: nil
    t.integer "position"
    t.string "title", limit: 255
    t.text "data_meta"
    t.string "image_id", limit: 255
    t.string "image_content_type", limit: 255
    t.string "image_filename", limit: 255
    t.integer "image_size"
    t.string "url"
    t.index ["record_id"], name: "index_photos_on_record_id"
  end

  create_table "prices", id: :serial, force: :cascade do |t|
    t.string "cached_artist", limit: 255
    t.string "media_type", limit: 255
    t.string "cached_label", limit: 255
    t.string "detail", limit: 255
    t.integer "price_low"
    t.integer "price_high"
    t.integer "yearbegin"
    t.integer "yearend"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "footnote"
    t.integer "artist_id"
    t.integer "label_id"
    t.integer "record_format_id"
    t.string "freebase_id", limit: 255
    t.integer "user_id"
    t.index ["cached_artist"], name: "index_prices_on_cached_artist_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["cached_label"], name: "index_prices_on_cached_label_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["detail"], name: "index_prices_on_detail_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["media_type"], name: "index_prices_on_media_type_trigram", opclass: :gin_trgm_ops, using: :gin
  end

  create_table "record_formats", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "record_type_id"
  end

  create_table "record_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "records", id: :serial, force: :cascade do |t|
    t.integer "genre_id"
    t.integer "value"
    t.text "comment"
    t.integer "price_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "condition"
    t.integer "user_id"
    t.integer "identifier_id"
    t.string "cached_artist", limit: 255
    t.string "cached_label", limit: 255
    t.integer "record_format_id"
    t.integer "artist_id"
    t.integer "label_id"
    t.index "to_tsvector('english'::regconfig, COALESCE(comment, ''::text))", name: "records_fts_idx", using: :gin
    t.index ["artist_id"], name: "index_records_on_artist_id"
    t.index ["genre_id"], name: "index_records_on_genre_id"
    t.index ["label_id"], name: "index_records_on_label_id"
    t.index ["price_id"], name: "index_records_on_price_id"
    t.index ["record_format_id"], name: "index_records_on_record_format_id"
    t.index ["user_id"], name: "index_records_on_user_id"
  end

  create_table "songs", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "mp3_file_name", limit: 255
    t.string "mp3_content_type", limit: 255
    t.integer "mp3_file_size"
    t.datetime "mp3_updated_at", precision: nil
    t.string "title", limit: 255
    t.string "panda_id", limit: 255
    t.string "audio_id", limit: 255
    t.string "audio_content_type", limit: 255
    t.string "audio_filename", limit: 255
    t.integer "audio_size"
    t.string "url"
    t.index ["record_id"], name: "index_songs_on_record_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 128, default: ""
    t.string "password_salt", limit: 255, default: ""
    t.string "reset_password_token", limit: 255
    t.string "remember_token", limit: 255
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.string "confirmation_token", limit: 255
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "username", limit: 255
    t.string "fname", limit: 255
    t.string "lname", limit: 255
    t.string "unconfirmed_email", limit: 255
    t.datetime "reset_password_sent_at", precision: nil
    t.string "invitation_token", limit: 255
    t.datetime "invitation_created_at", precision: nil
    t.datetime "invitation_sent_at", precision: nil
    t.datetime "invitation_accepted_at", precision: nil
    t.integer "invitation_limit"
    t.integer "invited_by_id"
    t.string "invited_by_type", limit: 255
    t.integer "invitations_count", default: 0
    t.string "slug", limit: 255
    t.string "avatar_id", limit: 255
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
