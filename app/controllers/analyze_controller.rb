require 'journey_questionnaire'
require 'fastercsv'
require 'iconv'

class AnalyzeController < ApplicationController
  layout "global", :except => [:rss, :csv]
  require_permission "view_answers", :class_name => "Questionnaire", :only => [:responses, :response_table, :aggregate]
  before_filter :check_edit_answers_permission, :only => [:edit_response, :update_response]

  def responses 
    sort = params[:sort_column] || 'id'
    if params[:reverse] == "true"
      sort = "#{sort} DESC"
    end
    
    @questionnaire = Questionnaire.find(params[:id])
    @rss_url = url_for :action => "rss", :id => @questionnaire.id, :secret => @questionnaire.rss_secret
    
    @responses = @questionnaire.valid_responses.paginate :page => params[:page]
    
    respond_to do |format|
      format.html # index.rhtml
      format.js do
        render :update do |page|
          page.replace_html 'responses', :partial => 'response_table'
        end
      end
    end
  end
  
  def response_table
    
  end
      
  def view_response
    @resp = Response.find(params[:id])
    @questionnaire = @resp.questionnaire
  end
  
  def edit_response
    @resp = Response.find(params[:id])
    @questionnaire = @resp.questionnaire
    @editing = true
  end
  
  def answer_given(question_id)
    return (params[:answer] and params[:answer][question_id.to_s] and
      params[:answer][question_id.to_s].length > 0)
  end
  
  def update_response
    @resp = Response.find(params[:id])
    @questionnaire = @resp.questionnaire

    @questionnaire.questions.each do |question|
      if question.kind_of? Field
        ans = Answer.find_answer(@resp, question)
        if answer_given(question.id)
          if ans.nil?
            ans = Answer.new :question_id => question.id, :response_id => @resp.id
          end
          ans.value = params[:answer][question.id.to_s]
          ans.save
        else
          # No answer provided
          if not ans.nil?
            ans.destroy
          end
        end
      end
    end
    
    render :action => 'view_response', :id => @resp.id
  end

  def rss
    @questionnaire = Questionnaire.find(params[:id])
    if params[:secret] != @questionnaire.rss_secret
      throw "Provided secret does not match questionnaire"
    end
    @responses = @questionnaire.valid_responses
  end
  
  def csv
    @questionnaire = Questionnaire.find(params[:id])
    @responses = @questionnaire.valid_responses
    @columns = @questionnaire.fields
    
    stream_csv(@questionnaire.title + ".csv") do |csv|
      if params[:rotate]
        csv << (["id"] + @responses.collect { |r| r.id })
        @columns.each do |col|
          csv << ([col.caption] + @responses.collect do |r|
            a = r.answer_for_question(col)
            if a
              a.output_value
            else
              ""
            end
          end)
        end
      else
        csv << (["id"] + @columns.collect { |c| c.caption })
        @responses.each do |resp|
          csv << ([resp.id] + @columns.collect do |c|
            a = resp.answer_for_question(c)
            if a
              a.output_value
            else
              ""
            end
          end)
        end
      end
    end
  end
  
  def aggregate
    @questionnaire = Questionnaire.find(params[:id])
    @fields = @questionnaire.fields.select { |f| not f.kind_of? FreeformField }
    
    @answercounts = {}
    @fields.each do |field|
      @answercounts[field.id] = {}
    end
    
    @fields.each do |question|
      @questionnaire.valid_responses.each do |resp|
        ans = resp.answer_for_question(question)
        val = (ans ? ans.output_value : nil) || "No answer"
        if val.length == 0
          val = "No answer"
        end
        if not @answercounts[question.id].has_key? val
          @answercounts[question.id][val] = 0
        end
        @answercounts[question.id][val] += 1
      end
    end
  end
  
  private
  def stream_csv(filename)
    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers['Content-type'] = 'text/plain'
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Expires'] = "0"
    else
      headers['Content-Type'] ||= 'text/csv'
    end
    headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
    
    output = StringIO.new
    csv = FasterCSV.new(output, :row_sep => "\r\n")
    yield csv
    begin
      c = Iconv.new('ISO-8859-15', 'UTF-8')
      render :text => c.iconv(output.string)
    rescue Iconv::IllegalSequence
      # this won't work in excel but might work other places
      render :text => output.string
    end
  end
  
  def check_edit_answers_permission
    @resp = Response.find(params[:id])
    @questionnaire = @resp.questionnaire
    if not logged_in? and logged_in_person.permitted?(@questionnaire, "edit_answers")
      access_denied
    end
  end
end
