class ResponseStatus < ActiveRecord::Migration[4.2]
  def self.up
    add_column "responses", "saved_page", :integer
    add_column "responses", "session_code", :string
  end

  def self.down
    remove_column "responses", "saved_page"
    remove_column "responses", "session_code"
  end
end
