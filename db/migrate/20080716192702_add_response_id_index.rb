class AddResponseIdIndex < ActiveRecord::Migration[4.2]
  def self.up
    add_index :answers, :response_id
  end

  def self.down
    remove_index :answers, :response_id
  end
end
