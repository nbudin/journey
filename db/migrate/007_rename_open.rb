class RenameOpen < ActiveRecord::Migration
  def self.up
    rename_column "questionnaires", "open", "is_open"
  end

  def self.down
    rename_column "questionnaires", "is_open", "open"
  end
end
