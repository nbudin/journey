class Ability
  include CanCan::Ability

  def initialize(person)
    alias_action :responseviewer, :print, :export, :aggregate, :subscribe, :to => :read
    
    can :read, Questionnaire, :is_open => true, :publicly_visible => true
    
    return unless person
    
    if person.admin?
      can :manage, :all 
    else
      can :create, Questionnaire
      can :read, Questionnaire, :questionnaire_permissions => { :person_id => person.id }
      can :update, Questionnaire, :questionnaire_permissions => { :person_id => person.id, :can_edit => true }
      can :destroy, Questionnaire, :questionnaire_permissions => { :person_id => person.id, :can_destroy => true }
      can :view_answers, Questionnaire, :questionnaire_permissions => { :person_id => person.id, :can_view_answers => true }
      can :view_answers, Questionnaire, :questionnaire_permissions => { :person_id => person.id, :can_edit_answers => true }
      can :change_permissions, Questionnaire, :questionnaire_permissions => { :person_id => person.id, :can_change_permissions => true }
      
      can :read, Response, Response.joins(:questionnaire => :questionnaire_permissions).where(:questionnaire_permissions => { :person_id => person.id }).where("can_view_answers = ? OR can_edit_answers = ?", true, true) do |resp|
        person.questionnaire_permissions.any? { |perm| (perm.can_view_answers? || perm.can_edit_answers?) && perm.questionnaire == resp.questionnaire }
      end
      can [:create, :update, :destroy], Response, Response.joins(:questionnaire => :questionnaire_permissions).where(:questionnaire_permissions => { :person_id => person.id, :can_edit_answers => true }) do |resp|
        person.questionnaire_permissions.any? { |perm| perm.can_edit_answers? && perm.questionnaire == resp.questionnaire }
      end
      can :destroy, Response, :person_id => person.id
      
      can :manage, Page, Page.joins(:questionnaire => :questionnaire_permissions).where(:questionnaire_permissions => { :person_id => person.id, :can_edit => true }) do |page|
        person.questionnaire_permissions.any? { |perm| perm.can_edit? && perm.questionnaire == page.questionnaire }
      end
      can :manage, Question, Question.joins(:page => { :questionnaire => :questionnaire_permissions}).where(:questionnaire_permissions => { :person_id => person.id, :can_edit => true }) do |question|
        person.questionnaire_permissions.any? { |perm| perm.can_edit? && perm.questionnaire == question.page.questionnaire }
      end
      can :manage, QuestionOption, QuestionOption.joins(:question => { :page => { :questionnaire => :questionnaire_permissions} }).where(:questionnaire_permissions => { :person_id => person.id, :can_edit => true }) do |question_option|
        person.questionnaire_permissions.any? { |perm| perm.can_edit? && perm.questionnaire == question_option.question.page.questionnaire }
      end
    end
  end
end