class AddResponseIdIndex < ActiveRecord::Migration
  def self.up
    add_index :answers, :response_id
  end

  def self.down
    remove_index :answers, :response_id
  end
end
