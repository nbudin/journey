class QuestionnairePermission < ActiveRecord::Base
  belongs_to :questionnaire
  belongs_to :person
  
  ACTIONS = %w(edit view_answers edit_answers destroy change_permissions).map(&:to_sym)
  
  named_scope :for_person, lambda { |person| { :conditions => { :person_id => person.id } } }
  named_scope :allows_anything, { :conditions => [ACTIONS.map { |a| "can_#{a} = ?" }.join(" OR "), *([true] * ACTIONS.size)] }
  
  validates_uniqueness_of :questionnaire_id, :scope => :person_id
end