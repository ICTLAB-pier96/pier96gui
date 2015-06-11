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

ActiveRecord::Schema.define(version: 20150611103401) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.string   "state"
    t.integer  "server_id"
    t.string   "ports"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "data_files", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "images", force: :cascade do |t|
    t.string   "repoid"
    t.string   "repo"
    t.string   "image"
    t.string   "created"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "filename"
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
    t.string   "os"
    t.string   "storage"
    t.string   "total_containers"
    t.string   "total_images"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "ram_usage"
    t.string   "disk_space"
  end

end
