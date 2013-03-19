class Ability
  include CanCan::Ability

  def initialize(person)
    alias_action :responseviewer, :print, :export, :aggregate, :subscribe, :to => :read
    
    can :read, Questionnaire, { :is_open => true, :publicly_visible => true }
    
    return unless person
    
    if person.admin?
      can :manage, :all 
    else
      can :create, Questionnaire
      can :read, Questionnaire, { :questionnaire_permissions => { :person_id => person.id } }
      can :update, Questionnaire, { :questionnaire_permissions => { :person_id => person.id, :can_edit => true } }
      can :destroy, Questionnaire, { :questionnaire_permissions => { :person_id => person.id, :can_destroy => true } }
      
      can :read, Response, { :questionnaire => { :questionnaire_permissions => { :person_id => person.id, :can_view_answers => true }}}
      can [:create, :update, :destroy], Response, { :questionnaire => { :questionnaire_permissions => { :person_id => person.id, :can_edit_answers => true }}}
      can :destroy, Response, { :person_id => person.id }
    end
  end
end