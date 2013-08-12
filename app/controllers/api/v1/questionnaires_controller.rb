class Api::V1::QuestionnairesController < ApplicationController
  respond_to :json
  load_and_authorize_resource
  
  def show
    respond_with @questionnaire
  end
end