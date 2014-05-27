class ApiController < ActionController::API
  include CanCan::ControllerAdditions
  include ActionController::MimeResponds # Devise needs it
  
  protected
  def current_ability
    Ability.new(current_person)
  end
end