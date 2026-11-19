class AddSubmittedFlag < ActiveRecord::Migration[4.2]
  def self.up
    add_column "responses", "submitted", :boolean, :default => false, :null => false
  end

  def self.down
    remove_column "responses", "submitted"
  end
end
