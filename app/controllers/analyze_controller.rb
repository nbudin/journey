require 'journey_questionnaire'
require 'iconv'

class AnalyzeController < ApplicationController
  layout "global", :except => [:rss, :csv]
  require_permission "view_answers", :class_name => "Questionnaire", :only => [:responses, :aggregate]
  before_filter :check_edit_answers_permission, :only => [:edit_response, :update_response]

  def responses 
    redirect_to responses_path(params[:id]), :status => :moved_permanently
  end
  
  def response_table
    
  end
  
  def view_response
    @questionnaire = Response.find(:id).questionnaire
    redirect_to response_path(@questionnaire, params[:id]), :status => :moved_permanently
  end
  
  def edit_response
    @questionnare = Response.find(:id).questionnaire
    redirect_to edit_response_path(@questionnaire, params[:id]), :status => :moved_permanently
  end
  
  def update_response
    @questionnaire = Response.find(params[:id]).questionnaire
    redirect_to response_path(@questionnaire, params[:id]), :status => :moved_permanently
  end
  
  def rss
    redirect_to responses_url(params[:id], :format => "rss", :secret => params[:secret]), :status => :moved_permanently
  end
  
  def csv
    redirect_to responses_url(params[:id], :format => "csv"), :status => :moved_permanently
  end
  
  def aggregate
    redirect_to responses_path(@questionnaire) + "/aggregate", :status => :moved_permanently
  end
  
  private
  
  def check_edit_answers_permission
    @resp = Response.find(params[:id])
    @questionnaire = @resp.questionnaire
    if not person_signed_in? and logged_in_person.permitted?(@questionnaire, "edit_answers")
      access_denied
    end
  end
end
