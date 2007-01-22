require 'journey_questionnaire'

class AnalyzeController < ApplicationController
  layout "global", :except => "rss"

  def responses 
    @items_per_page = params[:items_per_page] || 20
    sort = params[:sort_column] || 'id'
    if params[:reverse] == "true"
      sort = "#{sort} DESC"
    end
    
    @questionnaire = Questionnaire.find(params[:id])
    @rss_url = url_for :action => "rss", :id => @questionnaire.id, :secret => @questionnaire.rss_secret
    
    conditions = ["questionnaire_id = ? and id in (select response_id from answers where value is not null and value != '')",
      @questionnaire.id]
    
    @count = Response.count(:conditions => conditions)
    @responses_pages, @responses = paginate(:responses, :order => sort, :conditions => conditions, 
      :per_page => @items_per_page)
    
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
    @responses = @questionnaire.responses.select { |r| r.submitted or r.session_code }
  end
  
  def aggregate
    @questionnaire = Questionnaire.find(params[:id])
    @answers = @questionnaire.responses.collect { |r| r.submitted ? r.answers : nil }
    @answers.flatten!
    @answers = @answers.select { |a| not a.nil? }
    @fields = @questionnaire.pages.collect do |page|
        page.questions.select { |question| question.kind_of? Field and
                                not question.kind_of? FreeformField }
    end
    @fields.flatten!
    
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
end
