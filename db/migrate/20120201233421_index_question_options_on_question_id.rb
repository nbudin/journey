class IndexQuestionOptionsOnQuestionId < ActiveRecord::Migration[4.2]
  def self.up
    add_index :question_options, :question_id
  end

  def self.down
    remove_index :question_options, :question_id
  end
end
