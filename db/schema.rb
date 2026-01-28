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

ActiveRecord::Schema[8.1].define(version: 2026_01_28_132815) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "field_changed"
    t.jsonb "metadata", default: {}
    t.text "new_value"
    t.text "old_value"
    t.bigint "trackable_id", null: false
    t.string "trackable_type", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_activities_on_action"
    t.index ["created_at"], name: "index_activities_on_created_at"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable_type_and_trackable_id"
  end

  create_table "agents", force: :cascade do |t|
    t.string "address_line1"
    t.string "address_line2"
    t.string "agency_name"
    t.string "agency_website"
    t.string "city"
    t.decimal "commission_rate", precision: 5, scale: 2, default: "15.0"
    t.string "country", default: "USA"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name", null: false
    t.text "genres_represented"
    t.string "last_name", null: false
    t.text "notes"
    t.string "phone"
    t.string "postal_code"
    t.string "state"
    t.string "status", default: "active"
    t.datetime "updated_at", null: false
    t.index ["agency_name"], name: "index_agents_on_agency_name"
    t.index ["email"], name: "index_agents_on_email", unique: true, where: "(email IS NOT NULL)"
    t.index ["last_name", "first_name"], name: "index_agents_on_last_name_and_first_name"
    t.index ["status"], name: "index_agents_on_status"
  end

  create_table "authors", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "email"
    t.string "first_name", null: false
    t.string "genre_focus"
    t.string "last_name", null: false
    t.text "notes"
    t.string "phone"
    t.string "status", default: "active"
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["email"], name: "index_authors_on_email", unique: true, where: "(email IS NOT NULL)"
    t.index ["last_name", "first_name"], name: "index_authors_on_last_name_and_first_name"
    t.index ["status"], name: "index_authors_on_status"
  end

  create_table "books", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.string "cover_image_url"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "format"
    t.string "genre", null: false
    t.string "isbn"
    t.decimal "list_price", precision: 8, scale: 2
    t.text "notes"
    t.integer "page_count"
    t.date "publication_date"
    t.string "status", default: "manuscript"
    t.string "subgenre"
    t.string "subtitle"
    t.text "synopsis"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "word_count"
    t.index ["author_id"], name: "index_books_on_author_id"
    t.index ["genre"], name: "index_books_on_genre"
    t.index ["isbn"], name: "index_books_on_isbn", unique: true, where: "(isbn IS NOT NULL)"
    t.index ["publication_date"], name: "index_books_on_publication_date"
    t.index ["status"], name: "index_books_on_status"
    t.index ["title"], name: "index_books_on_title"
  end

  create_table "deals", force: :cascade do |t|
    t.decimal "advance_amount", precision: 12, scale: 2
    t.string "advance_currency", default: "USD"
    t.bigint "agent_id"
    t.bigint "book_id", null: false
    t.date "contract_date"
    t.datetime "created_at", null: false
    t.string "deal_type", null: false
    t.date "delivery_date"
    t.text "notes"
    t.date "offer_date"
    t.integer "option_books"
    t.date "publication_date"
    t.bigint "publisher_id", null: false
    t.decimal "royalty_rate_ebook", precision: 5, scale: 2
    t.decimal "royalty_rate_hardcover", precision: 5, scale: 2
    t.decimal "royalty_rate_paperback", precision: 5, scale: 2
    t.string "status", default: "negotiating"
    t.text "terms_summary"
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_deals_on_agent_id"
    t.index ["book_id"], name: "index_deals_on_book_id"
    t.index ["contract_date"], name: "index_deals_on_contract_date"
    t.index ["deal_type"], name: "index_deals_on_deal_type"
    t.index ["offer_date"], name: "index_deals_on_offer_date"
    t.index ["publisher_id"], name: "index_deals_on_publisher_id"
    t.index ["status"], name: "index_deals_on_status"
  end

  create_table "prospects", force: :cascade do |t|
    t.bigint "agent_id"
    t.datetime "created_at", null: false
    t.text "decline_reason"
    t.string "email"
    t.integer "estimated_word_count"
    t.string "first_name", null: false
    t.date "follow_up_date"
    t.string "genre_interest"
    t.date "last_contact_date"
    t.string "last_name", null: false
    t.text "notes"
    t.string "phone"
    t.text "project_description"
    t.string "project_title"
    t.string "source"
    t.string "stage", default: "new"
    t.datetime "stage_changed_at"
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_prospects_on_agent_id"
    t.index ["follow_up_date"], name: "index_prospects_on_follow_up_date"
    t.index ["last_name", "first_name"], name: "index_prospects_on_last_name_and_first_name"
    t.index ["source"], name: "index_prospects_on_source"
    t.index ["stage"], name: "index_prospects_on_stage"
  end

  create_table "publishers", force: :cascade do |t|
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.string "contact_email"
    t.string "contact_name"
    t.string "contact_phone"
    t.string "country", default: "USA"
    t.datetime "created_at", null: false
    t.string "imprint"
    t.string "name", null: false
    t.text "notes"
    t.string "phone"
    t.string "postal_code"
    t.string "size"
    t.string "state"
    t.string "status", default: "active"
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["name"], name: "index_publishers_on_name"
    t.index ["size"], name: "index_publishers_on_size"
    t.index ["status"], name: "index_publishers_on_status"
  end

  create_table "representations", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.bigint "author_id", null: false
    t.datetime "created_at", null: false
    t.date "end_date"
    t.text "notes"
    t.boolean "primary", default: false
    t.date "start_date"
    t.string "status", default: "active"
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_representations_on_agent_id"
    t.index ["author_id", "agent_id"], name: "index_representations_on_author_id_and_agent_id", unique: true
    t.index ["author_id"], name: "index_representations_on_author_id"
    t.index ["status"], name: "index_representations_on_status"
  end

  add_foreign_key "books", "authors"
  add_foreign_key "deals", "agents"
  add_foreign_key "deals", "books"
  add_foreign_key "deals", "publishers"
  add_foreign_key "prospects", "agents"
  add_foreign_key "representations", "agents"
  add_foreign_key "representations", "authors"
end
