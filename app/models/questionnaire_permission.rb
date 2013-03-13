class QuestionnairePermission < ActiveRecord::Base
  belongs_to :questionnaire
  belongs_to :person
  
  validates_uniqueness_of :questionnaire_id, :scope => :person_id
end