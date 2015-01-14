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

ActiveRecord::Schema.define(version: 20150113042739) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "courses", force: :cascade do |t|
    t.string   "crn",             limit: 255
    t.string   "gwid",            limit: 255
    t.string   "section",         limit: 255
    t.string   "course_name",     limit: 255
    t.string   "hours",           limit: 255
    t.string   "days",            limit: 255
    t.string   "day1_start",      limit: 255
    t.string   "day1_end",        limit: 255
    t.string   "day2_start",      limit: 255
    t.string   "day2_end",        limit: 255
    t.string   "day3_start",      limit: 255
    t.string   "day3_end",        limit: 255
    t.string   "day4_start",      limit: 255
    t.string   "day4_end",        limit: 255
    t.string   "day5_start",      limit: 255
    t.string   "day5_end",        limit: 255
    t.string   "day6_start",      limit: 255
    t.string   "day6_end",        limit: 255
    t.string   "day7_start",      limit: 255
    t.string   "day7_end",        limit: 255
    t.boolean  "llm_only"
    t.boolean  "jd_only"
    t.string   "course_name_2",   limit: 255
    t.boolean  "alt_schedule"
    t.text     "additional_info"
    t.boolean  "manual_lock"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "professor"
  end

  add_index "courses", ["crn"], name: "index_courses_on_crn", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "provider",   limit: 255
    t.string   "uid",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
