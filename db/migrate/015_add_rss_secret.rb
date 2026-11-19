class AddRssSecret < ActiveRecord::Migration[4.2]
  def self.up
    add_column "questionnaires", "rss_secret", :string
  end

  def self.down
    remove_column "questionnaires", "rss_secret"
  end
end
