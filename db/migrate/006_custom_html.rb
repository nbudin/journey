class CustomHtml < ActiveRecord::Migration
  def self.up
    add_column "questionnaires", "custom_html", :text, :default => "", :null => false
    add_column "questionnaires", "custom_css", :text, :default => "", :null => false
  end

  def self.down
    remove_column "questionnaires", "custom_html"
    remove_column "questionnaires", "custom_css"
  end
end
