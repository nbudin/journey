class IndexQuestionOptionsOnQuestionId < ActiveRecord::Migration
  def self.up
    add_index :question_options, :question_id
  end

  def self.down
    remove_index :question_options, :question_id
  end
end
