class CleanUpTheBadSpecialFieldAssociations < ActiveRecord::Migration
  def up
    SpecialFieldAssociation.where(question_id: nil).delete_all
    SpecialFieldAssociation.where(
      "questionnaire_id IS NULL AND question_id IS NOT NULL AND question_id NOT IN (SELECT id FROM questions)"
    ).delete_all
  end

  def down
  end
end
