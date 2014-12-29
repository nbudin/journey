class Person < ActiveRecord::Base
  devise :cas_authenticatable, :trackable
  
  has_many :questionnaire_permissions
  has_many :email_notifications

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
    questionnaire_permissions.find_by(:questionnaire_id => questionnaire.id)
  end
  
  def can?(action, questionnaire)
    return true if admin?
    
    permission = permission_for(questionnaire)
    permission && permission.send("can_#{action}?")
  end
  
  QuestionnairePermission::ACTIONS.each do |action|
    define_method "can_#{action}?" do |survey|
      can? action, survey
    end
  end
end