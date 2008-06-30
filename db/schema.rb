# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 9) do

  create_table "app_values", :force => true do |t|
    t.integer  "dict_id",                    :null => false
    t.string   "name",        :limit => 128, :null => false
    t.string   "desc"
    t.string   "code",        :limit => 8
    t.integer  "value_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "databases", :force => true do |t|
    t.integer  "driver_id"
    t.string   "name",        :limit => 64
    t.string   "path"
    t.string   "description"
    t.string   "host"
    t.string   "username",    :limit => 32
    t.string   "password",    :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "drivers", :force => true do |t|
    t.string   "name",       :limit => 64
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_permissions", :force => true do |t|
    t.integer  "group_id",      :null => false
    t.integer  "permission_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_permissions", ["group_id", "permission_id"], :name => "group_perms_group_perm", :unique => true

  create_table "groups", :force => true do |t|
    t.string   "name",       :limit => 32, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["name"], :name => "index_groups_on_name", :unique => true

  create_table "permissions", :force => true do |t|
    t.string   "name",        :limit => 32, :null => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["name"], :name => "index_permissions_on_name", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"
  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"

  create_table "user_groups", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "group_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_groups", ["user_id", "group_id"], :name => "user_groups_user_group", :unique => true

  create_table "users", :force => true do |t|
    t.string   "username",    :limit => 16, :null => false
    t.string   "email",       :limit => 48, :null => false
    t.string   "passwd_hash", :limit => 40
    t.string   "passwd_salt", :limit => 40
    t.string   "fname",       :limit => 32, :null => false
    t.string   "lname",       :limit => 32, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["username"], :name => "index_users_on_username", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
