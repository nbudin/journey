class AddSubmittedFlag < ActiveRecord::Migration
  def self.up
    add_column "responses", "submitted", :boolean, :default => false, :null => false
  end

  def self.down
    remove_column "responses", "submitted"
  end
end
