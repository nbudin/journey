class GraphsController < ApplicationController
  require_permission "view_answers", :class_name => "Questionnaire", :id_param => "questionnaire_id"
  before_filter :get_questionnaire
  before_filter :set_geom
  
  def line
    @questions = @questionnaire.questions.all(:conditions => { :id => params[:question_ids] })
    @counts = {}
    @min = @questions.collect { |q| q.min }.min
    @max = @questions.collect { |q| q.max }.max
    @questions.each do |question|
      @counts[question] = aggregate_question(question)
    end
    render :layout => false
  end
  
  def pie
    @question = @questionnaire.questions.find(params[:question_id])
    @answercounts = aggregate_question(@question)
    render :layout => false
  end
  
  private
  def set_geom
    @geom = params[:geom] || "640x480"
  end
  
  def get_questionnaire
    @questionnaire = Questionnaire.find(params[:questionnaire_id])
  end
  
  def aggregate_question(question)
    counts = Answer.count( :conditions => { :question_id => question.id }, :group => "value" )
    no_answer = @questionnaire.responses.valid.no_answer_for(question).count()
    if no_answer > 0
      counts["No answer"] = no_answer
    end
    return counts
  end
end
