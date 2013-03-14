class Person < ActiveRecord::Base
  devise :cas_authenticatable, :trackable
  
  has_many :questionnaire_permissions

  def name
    "#{firstname} #{lastname}"
  end

  def cas_extra_attributes=(extra_attributes)
    extra_attributes.each do |name, value|
      case name.to_sym
      when :firstname
        self.firstname = value
      when :lastname
        self.lastname = value
      when :birthdate
        self.birthdate = value
      when :gender
        self.gender = value
      when :email
        self.email = value
      end
    end
  end
  
  def permission_for(questionnaire)
    questionnaire_permissions.first(:conditions => {:questionnaire_id => questionnaire.id})
  end
  
  def can?(action, questionnaire)
    permission = permission_for(questionnaire)
    permission && permission.send("can_#{action}?")
  end
  
  QuestionnairePermission::ACTIONS.each do |action|
    define_method "can_#{action}?" do |survey|
      can? action, survey
    end
  end
end