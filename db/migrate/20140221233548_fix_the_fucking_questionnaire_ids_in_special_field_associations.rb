class FixTheFuckingQuestionnaireIdsInSpecialFieldAssociations < ActiveRecord::Migration
  def up
    SpecialFieldAssociation.includes(:questionnaire, question: { page: :questionnaire }).find_each do |sfa|
      sfa.questionnaire = sfa.question.questionnaire
      sfa.save!
    end
  end

  def down
  end
end
