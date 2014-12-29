# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base  
  protect_from_forgery
  
  helper :question_answer
  helper :tabstrip
  helper :color
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
  
  protected
  
  def last_answer_prompt_or_root_path
    if (qid = (session.delete("prompting_questionnaire_id") || params[:prompting_questionnaire_id]))
      questionnaire_answer_path(qid)
    else
      root_path
    end
  end
  
  def after_sign_in_path_for(resource)
    last_answer_prompt_or_root_path
  end
  
  def after_sign_out_path_for(resource)
    last_answer_prompt_or_root_path
  end  
  
  def current_ability
    Ability.new(current_person)
  end
  
  def response_rss_url(questionnaire)
    polymorphic_url([questionnaire, :responses], format: "rss", secret: questionnaire.rss_secret)
  end
  helper_method :response_rss_url
end
