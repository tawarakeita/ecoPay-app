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

ActiveRecord::Schema[7.1].define(version: 2025_11_24_000001) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
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
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "kiosk_devices", force: :cascade do |t|
    t.string "device_uid"
    t.string "name"
    t.boolean "enabled"
    t.integer "merchant_id", null: false
    t.integer "mission_admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_uid"], name: "index_kiosk_devices_on_device_uid"
    t.index ["merchant_id"], name: "index_kiosk_devices_on_merchant_id"
    t.index ["mission_admin_id"], name: "index_kiosk_devices_on_mission_admin_id"
  end

  create_table "merchants", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.text "description"
    t.string "address"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "municipality_id"
    t.index ["email"], name: "index_merchants_on_email", unique: true
    t.index ["reset_password_token"], name: "index_merchants_on_reset_password_token", unique: true
  end

  create_table "mission_admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["email"], name: "index_mission_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_mission_admins_on_reset_password_token", unique: true
  end

  create_table "missions", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "point"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "unique_code"
    t.integer "mission_admin_id"
    t.integer "merchant_id"
    t.index ["merchant_id"], name: "index_missions_on_merchant_id"
    t.index ["mission_admin_id"], name: "index_missions_on_mission_admin_id"
    t.index ["unique_code"], name: "index_missions_on_unique_code", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "merchant_id", null: false
    t.integer "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "index_payments_on_merchant_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "point_transactions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "merchant_id"
    t.string "transaction_type"
    t.integer "amount"
    t.integer "mission_id"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mission_admin_id"
    t.index ["merchant_id"], name: "index_point_transactions_on_merchant_id"
    t.index ["mission_admin_id"], name: "index_point_transactions_on_mission_admin_id"
    t.index ["mission_id"], name: "index_point_transactions_on_mission_id"
    t.index ["user_id"], name: "index_point_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "kiosk_devices", "merchants"
  add_foreign_key "kiosk_devices", "mission_admins"
  add_foreign_key "missions", "merchants"
  add_foreign_key "missions", "mission_admins"
  add_foreign_key "payments", "merchants"
  add_foreign_key "payments", "users"
  add_foreign_key "point_transactions", "merchants"
  add_foreign_key "point_transactions", "mission_admins"
  add_foreign_key "point_transactions", "missions"
  add_foreign_key "point_transactions", "users"
end
