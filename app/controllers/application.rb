# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'login_engine'

class ApplicationController < ActionController::Base
  model :question
  layout "global"
  
  #include LoginEngine
  #include UserEngine
  #helper :user
  #model :user
  
  #before_filter :authorize_action
end