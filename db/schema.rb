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

ActiveRecord::Schema[7.1].define(version: 2025_01_28_051444) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "covers", force: :cascade do |t|
    t.integer "cover_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.bigint "game_id"
    t.index ["game_id"], name: "index_covers_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.string "platforms"
    t.text "summary"
    t.string "url"
    t.integer "cover_id"
    t.integer "igdb_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "search_name"
    t.integer "total_rating_count"
    t.float "total_rating"
    t.string "genres"
  end

  create_table "genres", force: :cascade do |t|
    t.string "name"
    t.integer "genre_id"
    t.string "search_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "listings", force: :cascade do |t|
    t.float "price"
    t.text "description"
    t.integer "max"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "game_id"
    t.bigint "platform_id"
    t.index ["game_id"], name: "index_listings_on_game_id"
    t.index ["platform_id"], name: "index_listings_on_platform_id"
    t.index ["user_id"], name: "index_listings_on_user_id"
  end

  create_table "offers", force: :cascade do |t|
    t.text "comments"
    t.date "start_date"
    t.float "price"
    t.integer "period"
    t.bigint "listing_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.index ["listing_id"], name: "index_offers_on_listing_id"
    t.index ["user_id"], name: "index_offers_on_user_id"
  end

  create_table "platforms", force: :cascade do |t|
    t.integer "platform_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "search_name"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "username", default: "", null: false
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "latitude"
    t.float "longitude"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "covers", "games"
  add_foreign_key "listings", "games"
  add_foreign_key "listings", "platforms"
  add_foreign_key "listings", "users"
  add_foreign_key "offers", "listings"
  add_foreign_key "offers", "users"
end
