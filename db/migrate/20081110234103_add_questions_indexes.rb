class AddQuestionsIndexes < ActiveRecord::Migration
  def self.up
    add_index :questions, :page_id
    add_index :questions, [:page_id, :type]
  end

  def self.down
    remove_index :questions, :page_id
    remove_index :questions, [:page_id, :type]
  end
end
