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

ActiveRecord::Schema.define(version: 20150531141726) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "containers", force: :cascade do |t|
    t.string   "name"
    t.integer  "server_id"
    t.string   "ports"
    t.text     "description"
    t.integer  "image_id"
    t.integer  "host_port"
    t.integer  "local_port"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "images", force: :cascade do |t|
    t.string   "title"
    t.string   "date_added"
    t.string   "base_image"
    t.string   "filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "servers", force: :cascade do |t|
    t.string   "name"
    t.string   "host"
    t.string   "user"
    t.string   "password"
    t.string   "daemon_status"
    t.boolean  "status"
    t.string   "os"
    t.string   "storage"
    t.string   "total_containers"
    t.string   "total_images"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

end
