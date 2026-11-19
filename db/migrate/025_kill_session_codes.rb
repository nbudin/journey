class KillSessionCodes < ActiveRecord::Migration[4.2]
  def self.up
    remove_column "responses", "session_code"
    rename_column "responses", "user_id", "person_id"
  end

  def self.down
    rename_column "responses", "person_id", "user_id"
    add_column "responses", "session_code", :string
  end
end
