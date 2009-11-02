# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  layout :default_layout
  helper :user_options
  helper :question_answer
  helper :tabstrip
  
  private
  def default_layout
    Journey::SiteOptions.default_layout
  end
end
