class GraphsController < ApplicationController
  load_resource :questionnaire
  before_filter :set_geom
  
  def line
    authorize! :view_answers, @questionnaire
    
    @questions = Question.where(id: params[:question_ids]).all
    @counts = aggregate_questions(params[:question_ids])
    @min = @questions.collect { |q| q.min }.min
    @max = @questions.collect { |q| q.max }.max
    render :layout => false
  end
  
  def pie
    authorize! :view_answers, @questionnaire
    
    @answercounts = aggregate_questions(params[:question_id]).values.first
    @question = Question.find(params[:question_id])
    render :layout => false
  end
  
  private
  def set_geom
    @geom = params[:geom] || "640x480"
  end
  
  def aggregate_questions(question_ids)
    db = RailsSequel.connect
    
    skip_no_answer = params[:skip_no_answer]
          
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
      value = (db_row[:output_value] || db_row[:value])
      if value.blank?
        if skip_no_answer
          next
        else
          value = "No answer"
        end
      end
      
      counts[question_id] ||= {}
      counts[question_id][value] ||= 0
      counts[question_id][value] += 1
    end
    
    unless skip_no_answer
      Question.where(id: question_ids).find_each do |question|
        no_answer = @questionnaire.responses.valid.no_answer_for(question).count()
        if no_answer > 0
          counts[question.id]["No answer"] = no_answer
        end
      end
    end
    
    return counts
  end
end
