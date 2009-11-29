# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :user_options
  helper :question_answer
  helper :tabstrip
  helper :color
end
