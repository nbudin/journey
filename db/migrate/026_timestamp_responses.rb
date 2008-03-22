class TimestampResponses < ActiveRecord::Migration
  def self.up
    add_column "responses", "created_at", :datetime
    add_column "responses", "updated_at", :datetime
    add_column "responses", "submitted_at", :datetime
  end

  def self.down
    remove_column "responses", "created_at"
    remove_column "responses", "updated_at"
    remove_column "responses", "submitted_at"
  end
end
