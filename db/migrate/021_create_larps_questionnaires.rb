class CreateLarpsQuestionnaires < ActiveRecord::Migration
  def self.up
    create_table :larps_questionnaires, :id => false do |t|
      t.column :larp_id, :integer
      t.column :questionnaire_id, :integer
    end
  end

  def self.down
    drop_table :larps_questionnaires
  end
end
