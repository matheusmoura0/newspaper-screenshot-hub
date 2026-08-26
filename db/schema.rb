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

ActiveRecord::Schema[8.1].define(version: 2026_08_26_200714) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "activity_logs", force: :cascade do |t|
    t.string "action"
    t.bigint "auditable_id"
    t.string "auditable_type"
    t.datetime "created_at", null: false
    t.jsonb "metadata"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_activity_logs_on_user_id"
  end

  create_table "capture_runs", force: :cascade do |t|
    t.integer "completed_count"
    t.datetime "created_at", null: false
    t.text "error_summary"
    t.integer "expected_count"
    t.integer "failed_count"
    t.datetime "finished_at"
    t.date "scheduled_for"
    t.datetime "started_at"
    t.integer "status"
    t.datetime "updated_at", null: false
  end

  create_table "newspapers", force: :cascade do |t|
    t.boolean "active"
    t.jsonb "capture_options"
    t.time "capture_time"
    t.string "category"
    t.string "country"
    t.datetime "created_at", null: false
    t.boolean "desktop_enabled"
    t.string "homepage_url"
    t.boolean "mobile_enabled"
    t.string "name"
    t.string "slug"
    t.string "time_zone"
    t.datetime "updated_at", null: false
  end

  create_table "screenshots", force: :cascade do |t|
    t.integer "attempts"
    t.bigint "capture_run_id", null: false
    t.datetime "captured_at"
    t.date "captured_on"
    t.datetime "created_at", null: false
    t.integer "duration_ms"
    t.string "error_code"
    t.text "error_message"
    t.integer "height"
    t.jsonb "metadata"
    t.bigint "newspaper_id", null: false
    t.string "source_url"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.integer "viewport"
    t.integer "width"
    t.index ["capture_run_id"], name: "index_screenshots_on_capture_run_id"
    t.index ["newspaper_id"], name: "index_screenshots_on_newspaper_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "accepted_invitation_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.datetime "invited_at"
    t.datetime "last_sign_in_at"
    t.string "name"
    t.string "password_digest", null: false
    t.integer "role"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activity_logs", "users"
  add_foreign_key "screenshots", "capture_runs"
  add_foreign_key "screenshots", "newspapers"
  add_foreign_key "sessions", "users"
end
