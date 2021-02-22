# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_02_22_154607) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "esrb_content_descriptors", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "esrb_interactive_elements", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "esrb_rating_categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "game_content_descriptors", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "esrb_content_descriptor_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["esrb_content_descriptor_id"], name: "index_game_content_descriptors_on_esrb_content_descriptor_id"
    t.index ["game_id"], name: "index_game_content_descriptors_on_game_id"
  end

  create_table "game_interactive_elements", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "esrb_interactive_element_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["esrb_interactive_element_id"], name: "index_game_interactive_elements_on_esrb_interactive_element_id"
    t.index ["game_id"], name: "index_game_interactive_elements_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.text "rating_summary"
    t.bigint "esrb_rating_category_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["esrb_rating_category_id"], name: "index_games_on_esrb_rating_category_id"
  end

  create_table "kids", force: :cascade do |t|
    t.string "name"
    t.date "birthdate"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_kids_on_user_id"
  end

  create_table "user_reviews", force: :cascade do |t|
    t.integer "age"
    t.string "title"
    t.text "description"
    t.integer "rating"
    t.bigint "user_id", null: false
    t.bigint "game_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_user_reviews_on_game_id"
    t.index ["user_id"], name: "index_user_reviews_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "game_content_descriptors", "esrb_content_descriptors"
  add_foreign_key "game_content_descriptors", "games"
  add_foreign_key "game_interactive_elements", "esrb_interactive_elements"
  add_foreign_key "game_interactive_elements", "games"
  add_foreign_key "games", "esrb_rating_categories"
  add_foreign_key "kids", "users"
  add_foreign_key "user_reviews", "games"
  add_foreign_key "user_reviews", "users"
end
