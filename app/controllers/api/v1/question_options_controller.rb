class Api::V1::QuestionOptionsController < ApplicationController
  respond_to :json
  load_and_authorize_resource except: [:index]
    
  def index
    scope = QuestionOption.accessible_by(current_ability)
    scope = scope.where(id: params[:ids]) if params[:ids].present?
    respond_with scope.all
  end
  
  def show
    respond_with @question_option
  end
  
  def create
    @question_option = QuestionOption.create(params[:question_option])
    respond_with @question_option.question.page.questionnaire, @question_option.question.page, @question_option.question, @question_option
  end
  
  def destroy
    @question_option.destroy
    head :no_content
  end
  
  def update
    @question_option.update_attributes(params[:question_option])
    head :no_content
  end
end