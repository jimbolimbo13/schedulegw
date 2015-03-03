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

ActiveRecord::Schema.define(version: 20150302000034) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "final_date"
    t.string   "final_time"
    t.string   "school"
    t.integer  "schedule_id"
  end

  add_index "courses", ["crn"], name: "index_courses_on_crn", unique: true, using: :btree

  create_table "schedules", force: :cascade do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "course_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string   "name"
    t.text     "display_name"
    t.string   "email_stub"
    t.string   "initials"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "provider"
    t.string   "uid"
    t.text     "subscribed_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",          default: false
    t.string   "email"
    t.integer  "school_id"
  end

end
