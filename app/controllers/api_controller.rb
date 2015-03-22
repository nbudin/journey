class ApiController < ActionController::API
  include CanCan::ControllerAdditions
  extend Responders::ControllerMethod
  include ActionController::RespondWith
  include ActionController::ImplicitRender
  
  protected
  def current_ability
    Ability.new(current_person)
  end
end