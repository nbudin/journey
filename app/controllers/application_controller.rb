# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :user_options
  helper :question_answer
  helper :tabstrip
  helper :color
  
  def response_rss_url(questionnaire)
    responses_url(questionnaire, :format => "rss", :secret => questionnaire.rss_secret)
  end
  helper_method :response_rss_url
end
