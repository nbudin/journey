class CustomHtml < ActiveRecord::Migration
  def self.up
    add_column "questionnaires", "custom_html", :text
    add_column "questionnaires", "custom_css", :text
  end

  def self.down
    remove_column "questionnaires", "custom_html"
    remove_column "questionnaires", "custom_css"
  end
end
