# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base  
  protect_from_forgery
  
  helper :user_options
  helper :question_answer
  helper :tabstrip
  helper :color
  
  helper Xebec::NavBarHelper
  include Xebec::ControllerSupport  

  nav_bar :user_options, :class => "user_options" do |nb|
    Journey::UserOptions.hooks.each do |hook|
      hook.call(nb, self)
    end
    
    if person_signed_in?
      profile_name = current_person.name.present? ? current_person.name : "My profile"
      nb.nav_item profile_name, IllyanClient.base_url
      nb.nav_item "Log out", destroy_person_session_path, :method => :delete
    else
      nb.nav_item "Log in", new_person_session_path unless person_signed_in?
    end
  end
  
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
