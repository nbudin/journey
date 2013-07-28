class JourneyCasSessionsController < Devise::CasSessionsController
  before_filter :save_questionnaire_id, only: :new
  
  private
  def save_questionnaire_id
    session["prompting_questionnaire_id"] = params[:prompting_questionnaire_id] if params[:prompting_questionnaire_id]
  end
end