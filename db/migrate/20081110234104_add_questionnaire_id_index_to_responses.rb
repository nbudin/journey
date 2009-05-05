class AddQuestionnaireIdIndexToResponses < ActiveRecord::Migration
  def self.up
    add_index :responses, :questionnaire_id
  end

  def self.down
    remove_index :responses, :questionnaire_id
  end
end
