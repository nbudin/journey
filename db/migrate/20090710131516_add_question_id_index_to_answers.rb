class AddQuestionIdIndexToAnswers < ActiveRecord::Migration[4.2]
  def self.up
    add_index :answers, :question_id
  end

  def self.down
    remove_index :answers, :question_id
  end
end
