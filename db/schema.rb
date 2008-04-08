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

ActiveRecord::Schema.define(:version => 29) do

  create_table "answers", :force => true do |t|
    t.integer  "response_id"
    t.integer  "question_id", :default => 0, :null => false
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "characters", :force => true do |t|
    t.string  "name"
    t.integer "larp_id"
  end

  create_table "checkouts", :force => true do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.string  "path"
  end

  create_table "larp_runs", :force => true do |t|
    t.integer  "larp_id"
    t.string   "venue"
    t.datetime "when"
  end

  create_table "larps", :force => true do |t|
    t.string "name"
  end

  create_table "larps_questionnaires", :id => false, :force => true do |t|
    t.integer "larp_id"
    t.integer "questionnaire_id"
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "pages", :force => true do |t|
    t.integer "questionnaire_id", :null => false
    t.integer "position"
    t.string  "title"
  end

  create_table "permissions", :force => true do |t|
    t.integer "role_id"
    t.string  "permission"
    t.integer "permissioned_id"
    t.string  "permissioned_type"
    t.integer "person_id"
  end

  create_table "players", :id => false, :force => true do |t|
    t.integer "larp_run_id"
    t.integer "user_id"
  end

  add_index "players", ["larp_run_id", "user_id"], :name => "index_players_on_larp_run_id_and_user_id", :unique => true

  create_table "projects", :force => true do |t|
    t.string "name",     :null => false
    t.string "repo_url", :null => false
    t.string "username"
    t.string "password"
  end

  create_table "question_options", :force => true do |t|
    t.integer "question_id", :null => false
    t.text    "option",      :null => false
    t.integer "position",    :null => false
  end

  create_table "questionnaires", :force => true do |t|
    t.text    "title"
    t.boolean "is_open"
    t.string  "custom_html",          :default => ""
    t.string  "custom_css",           :default => ""
    t.boolean "allow_finish_later",   :default => true, :null => false
    t.boolean "allow_amend_response", :default => true, :null => false
    t.string  "rss_secret"
    t.text    "welcome_text"
  end

  create_table "questions", :force => true do |t|
    t.string  "type",           :limit => 100, :default => "",    :null => false
    t.integer "position",                      :default => 0,     :null => false
    t.text    "caption",                                          :null => false
    t.boolean "required",                      :default => false, :null => false
    t.integer "min",                           :default => 0,     :null => false
    t.integer "max",                           :default => 0,     :null => false
    t.integer "step",                          :default => 1,     :null => false
    t.integer "page_id",                                          :null => false
    t.string  "default_answer"
  end

  create_table "responses", :force => true do |t|
    t.integer  "questionnaire_id", :default => 0,     :null => false
    t.integer  "saved_page"
    t.boolean  "submitted",        :default => false, :null => false
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "submitted_at"
  end

  create_table "special_field_associations", :force => true do |t|
    t.integer "questionnaire_id"
    t.integer "question_id"
    t.string  "purpose"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "tagged_id"
    t.string   "tagged_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["tagged_id", "tagged_type"], :name => "index_taggings_on_tagged_id_and_tagged_type"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

end
