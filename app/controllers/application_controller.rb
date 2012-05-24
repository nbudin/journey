# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
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
    
    if logged_in?
      nb.nav_item logged_in_person.name, {:controller => "/account", :action => "edit_profile" }
      nb.nav_item "Log out", {:controller => "/auth", :action => "logout" }
    else
      nb.nav_item "Log in", {:controller => "/auth", :action => "login" } unless logged_in?
    end
  end
  
  protected
  
  def response_rss_url(questionnaire)
    responses_url(questionnaire, :format => "rss", :secret => questionnaire.rss_secret)
  end
  helper_method :response_rss_url
end
