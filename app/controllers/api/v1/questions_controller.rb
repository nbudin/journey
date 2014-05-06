class Api::V1::QuestionsController < ApplicationController
  respond_to :json
  load_and_authorize_resource except: [:index]
    
  def index
    scope = Question.accessible_by(current_ability).includes(:question_options)
    scope = scope.where(id: params[:ids]) if params[:ids].present?
    respond_with scope.all
  end
  
  def show
    respond_with @question
  end
  
  def create
    @question = Question.new(params[:question])
    @question.caption ||= case @question
    when Questions::Field then "Click here to type a question."
    else ""
    end
    @question.save
    
    respond_with @question.page.questionnaire, @question.page, @question
  end
  
  def destroy
    @question.destroy
    head :no_content
  end
  
  def update
    @question.update_attributes(params[:question])
    head :no_content
  end
end