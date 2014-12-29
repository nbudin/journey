class RootController < ApplicationController
  before_filter :get_new_questionnaires, :only => [:welcome, :dashboard]
  
  def index
    redirect_to Journey::SiteOptions.site_root(person_signed_in?), :status => 307
  end
  
  def welcome
    return index if person_signed_in?
  end
  
  def dashboard
    return index unless person_signed_in?
    
    @page_title = "Dashboard"
    
    @my_questionnaires = QuestionnairePermission.for_person(current_person).allows_anything.
      order("questionnaire_id DESC").includes(:questionnaire).to_a.map(&:questionnaire).compact
    
    @responses = Response.where(:person_id => current_person.id).includes(:questionnaire).order(:created_at => :desc).limit(8)
  end
  
  private
  def get_new_questionnaires
    @new_questionnaires = Questionnaire.where(:publicly_visible => true, :is_open => true).order("published_at DESC").limit(8)
  end
end
