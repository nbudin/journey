class MoreFinishOptions < ActiveRecord::Migration
  def self.up
    add_column "questionnaires", "allow_finish_later", :boolean, :default => true, :null => false
    add_column "questionnaires", "allow_amend_response", :boolean, :default => true, :null => false
    add_column "responses", "user_id", :integer
  end

  def self.down
    remove_column "questionnaires", "allow_finish_later"
    remove_column "questionnaires", "allow_amend_response"
    remove_column "responses", "user_id"
  end
end
