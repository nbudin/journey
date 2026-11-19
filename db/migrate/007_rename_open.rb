class RenameOpen < ActiveRecord::Migration[4.2]
  def self.up
    rename_column "questionnaires", "open", "is_open"
  end

  def self.down
    rename_column "questionnaires", "is_open", "open"
  end
end
