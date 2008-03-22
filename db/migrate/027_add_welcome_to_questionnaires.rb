class AddWelcomeToQuestionnaires < ActiveRecord::Migration
  def self.up
    add_column "questionnaires", "welcome_text", :text
  end

  def self.down
    remove_column "questionnaires", "welcome_text"
  end
end
