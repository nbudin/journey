class AddTimestampsToQuestionnaires < ActiveRecord::Migration
  def self.up
    add_column "questionnaires", "created_at", :datetime
    add_column "questionnaires", "updated_at", :datetime
  end

  def self.down
    remove_column "questionnaires", "created_at"
    remove_column "questionnaires", "updated_at"
  end
end
