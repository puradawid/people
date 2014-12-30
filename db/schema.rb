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

ActiveRecord::Schema.define(version: 20141222105942) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abilities", force: true do |t|
    t.string   "name"
    t.string   "icon"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
  end

  create_table "abilities_users", id: false, force: true do |t|
    t.integer "ability_id", null: false
    t.integer "user_id",    null: false
  end

  add_index "abilities_users", ["ability_id"], name: "index_abilities_users_on_ability_id", using: :btree
  add_index "abilities_users", ["user_id"], name: "index_abilities_users_on_user_id", using: :btree

  create_table "admin_roles", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
  end

  create_table "contract_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
  end

  create_table "features", force: true do |t|
    t.string   "key"
    t.boolean  "enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
  end

  create_table "locations", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
  end

  create_table "memberships", force: true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "role_id"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "billable"
    t.boolean  "project_archived",  default: false
    t.boolean  "project_potential", default: true
    t.boolean  "project_internal",  default: true
    t.boolean  "stays",             default: false
    t.boolean  "booked",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
  end

  add_index "memberships", ["project_id"], name: "index_memberships_on_project_id", using: :btree
  add_index "memberships", ["role_id"], name: "index_memberships_on_role_id", using: :btree
  add_index "memberships", ["user_id"], name: "index_memberships_on_user_id", using: :btree

  create_table "notes", force: true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.text     "text"
    t.boolean  "open",       default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
  end

  add_index "notes", ["project_id"], name: "index_notes_on_project_id", using: :btree
  add_index "notes", ["user_id"], name: "index_notes_on_user_id", using: :btree

  create_table "positions", force: true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "starts_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
  end

  add_index "positions", ["role_id"], name: "index_positions_on_role_id", using: :btree
  add_index "positions", ["user_id"], name: "index_positions_on_user_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.datetime "end_at"
    t.boolean  "archived",       default: false
    t.boolean  "potential",      default: false
    t.boolean  "internal",       default: false
    t.datetime "kickoff"
    t.string   "project_type"
    t.string   "colour"
    t.string   "initials"
    t.string   "toggl_bookmark"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.string   "color"
    t.boolean  "billable",      default: false
    t.boolean  "technical",     default: false
    t.boolean  "show_in_team",  default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
    t.integer  "element_order", default: 0,     null: false
  end

  create_table "settings", force: true do |t|
    t.string   "notifications_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
  end

  create_table "teams", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
  end

  create_table "users", force: true do |t|
    t.string   "encrypted_password"
    t.integer  "sign_in_count",      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "team_join_time"
    t.string   "oauth_token"
    t.string   "refresh_token"
    t.datetime "oauth_expires_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "gh_nick"
    t.string   "skype"
    t.integer  "employment",         default: 0
    t.string   "phone"
    t.boolean  "archived",           default: false
    t.boolean  "available",          default: true
    t.boolean  "without_gh",         default: false
    t.string   "uid"
    t.string   "user_notes"
    t.integer  "admin_role_id"
    t.integer  "role_id"
    t.integer  "contract_type_id"
    t.integer  "location_id"
    t.integer  "team_id"
    t.integer  "leader_team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mongo_id"
  end

  add_index "users", ["admin_role_id"], name: "index_users_on_admin_role_id", using: :btree
  add_index "users", ["contract_type_id"], name: "index_users_on_contract_type_id", using: :btree
  add_index "users", ["leader_team_id"], name: "index_users_on_leader_team_id", using: :btree
  add_index "users", ["location_id"], name: "index_users_on_location_id", using: :btree
  add_index "users", ["role_id"], name: "index_users_on_role_id", using: :btree
  add_index "users", ["team_id"], name: "index_users_on_team_id", using: :btree

end
