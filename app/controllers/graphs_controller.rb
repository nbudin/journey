class GraphsController < ApplicationController
  require_permission "view_answers", :class_name => "Questionnaire", :id_param => "questionnaire_id"
  before_filter :get_questionnaire
  before_filter :set_geom
  
  def line
    @questions = Question.all(:conditions => { :id => params[:question_ids] })
    @counts = aggregate_questions(params[:question_ids])
    @min = @questions.collect { |q| q.min }.min
    @max = @questions.collect { |q| q.max }.max
    render :layout => false
  end
  
  def pie
    @answercounts = aggregate_questions(params[:question_id]).values.first
    @question = Question.find(params[:question_id])
    render :layout => false
  end
  
  private
  def set_geom
    @geom = params[:geom] || "640x480"
  end
  
  def get_questionnaire
    @questionnaire = Questionnaire.find(params[:questionnaire_id])
  end
  
  def aggregate_questions(question_ids)
    db = RailsSequel.connect
          
    ds = db[:answers]
    ds = ds.inner_join(:questions, :id => :answers__question_id)
    ds = ds.inner_join(:pages, :id => :questions__page_id)
    ds = ds.left_join(:question_options, :question_id => :answers__question_id, :option => :answers__value)
    ds = ds.where(:questions__id => question_ids)
    ds = ds.where(:pages__questionnaire_id => @questionnaire.id)
    ds = ds.select(:questions__id, :answers__value, :question_options__output_value)
    
    counts = {}
    ds.each do |db_row|
      question_id = db_row[:id]
      value = (db_row[:output_value] || db_row[:value] || "No answer")
      counts[question_id] ||= {}
      counts[question_id][value] ||= 0
      counts[question_id][value] += 1
    end
    
    Question.all(:conditions => { :id => question_ids }).each do |question|
      no_answer = @questionnaire.responses.valid.no_answer_for(question).count()
      if no_answer > 0
        counts[question.id]["No answer"] = no_answer
      end
    end
    
    return counts
  end
end
