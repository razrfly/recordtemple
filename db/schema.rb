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

ActiveRecord::Schema.define(version: 20170608171624) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

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

  create_table "blazer_audits", force: true do |t|
    t.integer  "user_id"
    t.integer  "query_id"
    t.text     "statement"
    t.string   "data_source"
    t.datetime "created_at"
  end

  create_table "blazer_checks", force: true do |t|
    t.integer  "query_id"
    t.string   "state"
    t.text     "emails"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blazer_dashboard_queries", force: true do |t|
    t.integer  "dashboard_id"
    t.integer  "query_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blazer_dashboards", force: true do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blazer_queries", force: true do |t|
    t.integer  "creator_id"
    t.string   "name"
    t.text     "description"
    t.text     "statement"
    t.string   "data_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "genres", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "genres", ["slug"], name: "index_genres_on_slug", unique: true, using: :btree

  create_table "labels", force: true do |t|
    t.string   "name"
    t.string   "freebase_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "labels", ["name"], name: "index_labels_on_name", unique: true, using: :btree
  add_index "labels", ["slug"], name: "index_labels_on_slug", unique: true, using: :btree

  create_table "pages", force: true do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "user_id"
    t.integer  "position"
    t.string   "cover_id"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["user_id"], name: "index_pages_on_user_id", using: :btree

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
    t.string   "image_id"
    t.string   "image_content_type"
    t.string   "image_filename"
    t.integer  "image_size"
  end

  add_index "photos", ["record_id"], name: "index_photos_on_record_id", using: :btree

  create_table "prices", force: true do |t|
    t.string   "cached_artist"
    t.string   "media_type"
    t.string   "cached_label"
    t.string   "detail"
    t.integer  "price_low"
    t.integer  "price_high"
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

  add_index "prices", ["cached_artist"], name: "index_prices_on_cached_artist_trigram", using: :gin
  add_index "prices", ["cached_label"], name: "index_prices_on_cached_label_trigram", using: :gin
  add_index "prices", ["detail"], name: "index_prices_on_detail_trigram", using: :gin
  add_index "prices", ["media_type"], name: "index_prices_on_media_type_trigram", using: :gin

  create_table "record_formats", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "record_type_id"
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
    t.integer  "record_format_id"
    t.integer  "artist_id"
    t.integer  "label_id"
  end

  add_index "records", ["artist_id"], name: "index_records_on_artist_id", using: :btree
  add_index "records", ["genre_id"], name: "index_records_on_genre_id", using: :btree
  add_index "records", ["label_id"], name: "index_records_on_label_id", using: :btree
  add_index "records", ["price_id"], name: "index_records_on_price_id", using: :btree
  add_index "records", ["record_format_id"], name: "index_records_on_record_format_id", using: :btree
  add_index "records", ["user_id"], name: "index_records_on_user_id", using: :btree

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
    t.string   "audio_id"
    t.string   "audio_content_type"
    t.string   "audio_filename"
    t.integer  "audio_size"
  end

  add_index "songs", ["record_id"], name: "index_songs_on_record_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                              default: "", null: false
    t.string   "encrypted_password",     limit: 128, default: ""
    t.string   "password_salt",                      default: ""
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "fname"
    t.string   "lname"
    t.string   "unconfirmed_email"
    t.datetime "reset_password_sent_at"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",                  default: 0
    t.string   "slug"
    t.string   "avatar_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree

        create_view :simple_searches, sql_definition:<<-SQL
          SELECT artists.id AS searchable_id,
    artists.name AS term,
    'Artist'::text AS searchable_type
   FROM (artists
     JOIN records ON ((records.artist_id = artists.id)))
UNION
 SELECT labels.id AS searchable_id,
    labels.name AS term,
    'Label'::text AS searchable_type
   FROM (labels
     JOIN records ON ((records.label_id = labels.id)))
UNION
 SELECT genres.id AS searchable_id,
    genres.name AS term,
    'Genre'::text AS searchable_type
   FROM (genres
     JOIN records ON ((records.genre_id = genres.id)))
UNION
 SELECT records.id AS searchable_id,
    array_to_string(ARRAY[prices.detail, prices.footnote, (records.comment)::character varying], ' '::text) AS term,
    'Record'::text AS searchable_type
   FROM (records
     LEFT JOIN prices ON ((records.price_id = prices.id)))
UNION
 SELECT songs.id AS searchable_id,
    songs.title AS term,
    'Song'::text AS searchable_type
   FROM (songs
     JOIN records ON ((songs.record_id = records.id)));
        SQL

end
