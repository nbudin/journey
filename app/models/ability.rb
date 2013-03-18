class Ability
  include CanCan::Ability

  def initialize(person)
    can :read, Questionnaire, { :is_open => true, :publicly_visible => true }
    
    return unless person
    
    if person.admin?
      can :manage, :all 
    else
      can [:read], Questionnaire, { :questionnaire_permissions => { :person_id => person.id } }
      can [:edit, :update], Questionnaire, { :questionnaire_permissions => { :person_id => person.id, :can_edit => true } }
      can [:delete], Questionnaire, { :questionnaire_permissions => { :person_id => person.id, :can_destroy => true } }
      
      can [:read, :responseviewer, :print, :export, :aggregate, :subscribe], Response, { :questionnaire => { :questionnaire_permissions => { :person_id => person.id, :can_view_answers => true }}}
      can [:edit, :update, :delete], Response, { :questionnaire => { :questionnaire_permissions => { :person_id => person.id, :can_edit_answers => true }}}
      can :delete, Response, { :person_id => person.id }
    end
  end
end