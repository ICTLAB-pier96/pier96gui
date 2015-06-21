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

ActiveRecord::Schema.define(version: 20150621140434) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "container_arguments", force: :cascade do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "containers", force: :cascade do |t|
    t.string   "args"
    t.string   "command"
    t.date     "created"
    t.text     "description"
    t.string   "image"
    t.string   "labels"
    t.string   "name"
    t.string   "local_port"
    t.string   "host_port"
    t.text     "state"
    t.integer  "server_id"
    t.string   "ports"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",         default: 0, null: false
    t.integer  "attempts",         default: 0, null: false
    t.text     "handler",                      null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "progress_stage"
    t.integer  "progress_current", default: 0
    t.integer  "progress_max",     default: 0
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "images", force: :cascade do |t|
    t.string   "title"
    t.string   "date_added"
    t.string   "base_image"
    t.string   "filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "status"
  end

  create_table "server_loads", force: :cascade do |t|
    t.integer  "server_id"
    t.integer  "ram_usage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "servers", force: :cascade do |t|
    t.string   "name"
    t.string   "host"
    t.string   "user"
    t.string   "password"
    t.boolean  "daemon_status"
    t.boolean  "status"
    t.string   "ram_usage"
    t.string   "disk_space"
    t.string   "os"
    t.string   "storage"
    t.string   "total_containers"
    t.string   "total_images"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

end
