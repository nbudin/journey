require 'journey_questionnaire'
require 'fastercsv'
require 'iconv'

class AnalyzeController < ApplicationController
  layout "global", :except => [:rss, :csv]
  require_permission "view_answers", :class_name => "Questionnaire", :only => [:responses, :response_table, :aggregate]

  def responses 
    sort = params[:sort_column] || 'id'
    if params[:reverse] == "true"
      sort = "#{sort} DESC"
    end
    
    @questionnaire = Questionnaire.find(params[:id])
    @rss_url = url_for :action => "rss", :id => @questionnaire.id, :secret => @questionnaire.rss_secret
    
    @responses = @questionnaire.valid_responses.paginate :page => params[:page]
    
    if request.xml_http_request?
      render :partial => 'response_table', :layout => false
    end
  end
  
  def response_table
    
  end
      
  def view_response
    @resp = Response.find(params[:id])
    @questionnaire = @resp.questionnaire
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
            ans = r.answer_for_question(col)
            ans ? ans.value : ""
          end)
        end
      else
        csv << (["id"] + @columns.collect { |c| c.caption })
        @responses.each do |resp|
          csv << ([resp.id] + @columns.collect do |c| 
            ans = resp.answer_for_question(c)
            ans ? ans.value : ""
          end)
        end
      end
    end
  end
  
  def aggregate
    @questionnaire = Questionnaire.find(params[:id])
    @answers = @questionnaire.responses.collect { |r| r.submitted ? r.answers : nil }
    @answers.flatten!
    @answers = @answers.select { |a| not a.nil? }
    @fields = @questionnaire.fields
    
    @answercounts = {}
    @fields.each do |field|
      @answercounts[field.id] = {}
    end
    
    @answers.each do |answer|
      if @fields.include? answer.question
        qid = answer.question.id
        val = answer.value || 'No answer'
        if val.length == 0
          val = 'No answer'
        end
        if not @answercounts[qid].has_key? val
          @answercounts[qid][val] = 0
        end
        @answercounts[qid][val] += 1
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
end
