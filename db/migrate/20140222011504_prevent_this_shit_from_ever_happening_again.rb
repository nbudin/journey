class PreventThisShitFromEverHappeningAgain < ActiveRecord::Migration
  def up
    change_table :special_field_associations do |t|
      t.change :questionnaire_id, :integer, null: false
      t.change :question_id, :integer, null: false
    end
  end

  def down
    change_table :special_field_associations do |t|
      t.change :questionnaire_id, :integer, null: true
      t.change :question_id, :integer, null: true
    end
  end
end
