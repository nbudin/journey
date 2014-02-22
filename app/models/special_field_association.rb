class SpecialFieldAssociation < ActiveRecord::Base
  belongs_to :question, :foreign_key => :question_id, :inverse_of => :special_field_association
  belongs_to :questionnaire, :foreign_key => :questionnaire_id, :inverse_of => :special_field_associations

  validates_inclusion_of :purpose, :in => Questionnaire.special_field_purposes
  
  after_save :set_questionnaire
  
  private
  def set_questionnaire
    self.questionnaire = question.try(:questionnaire)
  end
end
