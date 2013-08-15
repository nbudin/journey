class Api::V1::QuestionsController < ApplicationController
  respond_to :json
  load_and_authorize_resource except: [:index]
    
  def index
    scope = Question.accessible_by(current_ability)
    scope = scope.where(id: params[:ids]) if params[:ids].present?
    respond_with scope.all
  end
  
  def show
    respond_with @question
  end
end