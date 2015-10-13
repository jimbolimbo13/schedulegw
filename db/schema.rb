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

ActiveRecord::Schema.define(version: 20150814235613) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "booklistsuggestions", force: :cascade do |t|
    t.string   "gwid"
    t.string   "section"
    t.string   "crn"
    t.string   "isbn"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "coursebooks", force: :cascade do |t|
    t.integer  "listbook_id"
    t.integer  "course_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "coursebooks", ["course_id"], name: "index_coursebooks_on_course_id", using: :btree
  add_index "coursebooks", ["listbook_id"], name: "index_coursebooks_on_listbook_id", using: :btree

  create_table "courses", force: :cascade do |t|
    t.string   "crn"
    t.string   "gwid"
    t.string   "section"
    t.string   "course_name"
    t.string   "hours"
    t.string   "days"
    t.string   "day1_start"
    t.string   "day1_end"
    t.string   "day2_start"
    t.string   "day2_end"
    t.string   "day3_start"
    t.string   "day3_end"
    t.string   "day4_start"
    t.string   "day4_end"
    t.string   "day5_start"
    t.string   "day5_end"
    t.string   "day6_start"
    t.string   "day6_end"
    t.string   "day7_start"
    t.string   "day7_end"
    t.boolean  "llm_only"
    t.boolean  "jd_only"
    t.string   "course_name_2"
    t.boolean  "alt_schedule"
    t.text     "additional_info"
    t.boolean  "manual_lock"
    t.string   "professor"
    t.integer  "prof_id"
    t.string   "final_time"
    t.string   "final_date"
    t.string   "school"
    t.integer  "schedule_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "isbn",                   default: []
    t.boolean  "booklist_locked",        default: false
    t.boolean  "booklist_lock_conflict", default: false
    t.json     "wrong_isbn",             default: []
    t.json     "pinned_isbn",            default: []
    t.integer  "schedule_count",         default: 0
  end

  add_index "courses", ["crn"], name: "index_courses_on_crn", using: :btree

  create_table "courseschedules", force: :cascade do |t|
    t.string   "name_of_relation"
    t.integer  "course_id"
    t.integer  "schedule_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "courseschedules", ["course_id"], name: "index_courseschedules_on_course_id", using: :btree
  add_index "courseschedules", ["schedule_id"], name: "index_courseschedules_on_schedule_id", using: :btree

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "resolved"
    t.string   "crn"
    t.string   "gwid"
    t.string   "section"
    t.text     "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "listbooks", force: :cascade do |t|
    t.string   "title"
    t.string   "amzn_url"
    t.string   "isbn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "image_url"
  end

  create_table "professorlists", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "prof_id"
    t.string   "school"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schedules", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name",          default: "Unnamed Schedule"
    t.string   "unique_string"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "schedules", ["user_id"], name: "index_schedules_on_user_id", using: :btree

  create_table "schools", force: :cascade do |t|
    t.string   "name"
    t.text     "display_name"
    t.string   "email_stub"
    t.string   "initials"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.text     "final_date_options"
    t.text     "final_time_options"
    t.string   "crn_scrape_digest",      default: ""
    t.datetime "crn_last_scraped",       default: '2015-08-14 17:16:45'
    t.datetime "crn_last_checked",       default: '2015-08-14 17:16:45'
    t.string   "exam_scrape_digest",     default: ""
    t.datetime "exam_last_scraped",      default: '2015-08-14 17:16:45'
    t.datetime "exam_last_checked",      default: '2015-08-14 17:16:45'
    t.string   "booklist_scrape_digest", default: ""
    t.datetime "booklist_last_scraped",  default: '2015-08-14 17:16:45'
    t.datetime "booklist_last_checked",  default: '2015-08-14 17:16:45'
    t.integer  "emails_sent",            default: 0
    t.integer  "schedules_created",      default: 0
    t.string   "crn_url"
    t.string   "exam_url"
    t.string   "booklist_url"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "provider"
    t.string   "email"
    t.string   "uid"
    t.text     "subscribed_ids"
    t.boolean  "admin",            default: false
    t.integer  "school_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "accepted_terms",   default: false
    t.datetime "last_email_blast", default: '2015-08-11 17:16:45'
  end

end
