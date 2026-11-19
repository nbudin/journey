class CustomQuestionnaireAttributesNullable < ActiveRecord::Migration[4.2]
  def self.up
    change_column "questionnaires", "custom_html", :string, :null => true, :default => ''
    change_column "questionnaires", "custom_css", :string, :null => true, :default => ''
  end

  def self.down
    change_column "questionnaires", "custom_html", :string, :null => false
    change_column "questionnaires", "custom_css", :string, :null => false
  end
end
