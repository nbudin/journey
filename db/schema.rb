# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090609202935) do

  create_table "answers", :force => true do |t|
    t.integer  "response_id"
    t.integer  "question_id", :default => 0, :null => false
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["response_id"], :name => "index_answers_on_response_id"

  create_table "auth_tickets", :force => true do |t|
    t.string   "secret",     :limit => 40
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expires_at"
  end

  add_index "auth_tickets", ["secret"], :name => "secret", :unique => true

  create_table "characters", :force => true do |t|
    t.string  "name"
    t.integer "larp_id"
  end

  create_table "checkouts", :force => true do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.string  "path"
  end

  create_table "engine_schema_info", :id => false, :force => true do |t|
    t.string  "engine_name"
    t.integer "version"
  end

  create_table "entitlements", :force => true do |t|
    t.integer  "person_id"
    t.boolean  "unlimited"
    t.datetime "expires_at"
    t.integer  "open_questionnaires"
    t.integer  "responses_per_month"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entitlements", ["person_id"], :name => "index_entitlements_on_person_id"

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
    t.integer "questionnaire_id", :default => 0, :null => false
    t.integer "position"
    t.string  "title"
  end

  create_table "permission_caches", :force => true do |t|
    t.integer "person_id"
    t.integer "permissioned_id"
    t.string  "permissioned_type"
    t.string  "permission_name"
    t.boolean "result"
  end

  add_index "permission_caches", ["permission_name"], :name => "index_permission_caches_on_permission_name"
  add_index "permission_caches", ["permissioned_id", "permissioned_type"], :name => "index_permission_caches_on_permissioned"
  add_index "permission_caches", ["person_id"], :name => "index_permission_caches_on_person_id"

  create_table "permissions", :force => true do |t|
    t.integer "role_id"
    t.string  "permission"
    t.integer "permissioned_id"
    t.string  "permissioned_type"
    t.integer "person_id"
  end

  create_table "permissions_roles", :id => false, :force => true do |t|
    t.integer "permission_id", :default => 0, :null => false
    t.integer "role_id",       :default => 0, :null => false
  end

  create_table "players", :id => false, :force => true do |t|
    t.integer "larp_run_id"
    t.integer "user_id"
  end

  add_index "players", ["larp_run_id", "user_id"], :name => "index_players_on_larp_run_id_and_user_id", :unique => true

  create_table "plugin_schema_info", :id => false, :force => true do |t|
    t.string  "plugin_name"
    t.integer "version"
  end

  create_table "projects", :force => true do |t|
    t.string "name",     :null => false
    t.string "repo_url", :null => false
    t.string "username"
    t.string "password"
  end

  create_table "question_options", :force => true do |t|
    t.integer "question_id",  :default => 0, :null => false
    t.text    "option",                      :null => false
    t.integer "position"
    t.string  "output_value"
  end

  create_table "questionnaires", :force => true do |t|
    t.text     "title"
    t.boolean  "is_open"
    t.text     "custom_html"
    t.text     "custom_css"
    t.boolean  "allow_finish_later",   :default => true,  :null => false
    t.boolean  "allow_amend_response", :default => true,  :null => false
    t.string   "rss_secret"
    t.text     "welcome_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "advertise_login",      :default => true
    t.boolean  "require_login",        :default => false
    t.integer  "owner_id"
    t.integer  "subscription_id"
  end

  add_index "questionnaires", ["subscription_id"], :name => "index_questionnaires_on_subscription_id"

  create_table "questions", :force => true do |t|
    t.string  "type",           :limit => 100, :default => "",     :null => false
    t.integer "position"
    t.text    "caption",                                           :null => false
    t.boolean "required",                      :default => false,  :null => false
    t.integer "min",                           :default => 0,      :null => false
    t.integer "max",                           :default => 0,      :null => false
    t.integer "step",                          :default => 1,      :null => false
    t.integer "page_id",                       :default => 0,      :null => false
    t.text    "default_answer"
    t.string  "layout",                        :default => "left"
  end

  add_index "questions", ["page_id", "type"], :name => "index_questions_on_page_id_and_type"
  add_index "questions", ["page_id"], :name => "index_questions_on_page_id"

  create_table "responses", :force => true do |t|
    t.integer  "questionnaire_id", :default => 0,     :null => false
    t.integer  "saved_page"
    t.boolean  "submitted",        :default => false, :null => false
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "submitted_at"
  end

  add_index "responses", ["questionnaire_id"], :name => "index_responses_on_questionnaire_id"

  create_table "roles", :force => true do |t|
    t.string  "name",        :default => "",    :null => false
    t.string  "description"
    t.boolean "omnipotent",  :default => false, :null => false
    t.boolean "system_role", :default => false, :null => false
  end

  create_table "special_field_associations", :force => true do |t|
    t.integer "questionnaire_id"
    t.integer "question_id"
    t.string  "purpose"
  end

  create_table "subscription_plans", :force => true do |t|
    t.string  "name"
    t.boolean "unlimited"
    t.integer "open_questionnaires"
    t.integer "responses_per_month"
    t.string  "rebill_period"
    t.integer "price"
    t.integer "grace_period"
  end

  create_table "subscriptions", :force => true do |t|
    t.datetime "last_paid_at"
    t.integer  "subscription_plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "users", :force => true do |t|
    t.string   "login",           :limit => 80, :default => "", :null => false
    t.string   "salted_password", :limit => 40, :default => "", :null => false
    t.string   "email",           :limit => 60, :default => "", :null => false
    t.string   "firstname",       :limit => 40
    t.string   "lastname",        :limit => 40
    t.string   "salt",            :limit => 40, :default => "", :null => false
    t.integer  "verified",                      :default => 0
    t.string   "role",            :limit => 40
    t.string   "security_token",  :limit => 40
    t.datetime "token_expiry"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "logged_in_at"
    t.integer  "deleted",                       :default => 0
    t.datetime "delete_after"
  end

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id", :default => 0, :null => false
    t.integer "role_id", :default => 0, :null => false
  end

end
