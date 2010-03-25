class PublishController < ApplicationController
  require_permission "edit", :class_name => "Questionnaire", :id_param => "questionnaire_id"
  before_filter :get_questionnaire
  
  def index
    if @questionnaire.is_open
      render :action => "widgets"
    elsif Journey::SiteOptions.prepublish?
      redirect_to Journey::SiteOptions.prepublish_url_options(@questionnaire)
    end
  end
  
  def settings
  end

  private
  def get_questionnaire
    @questionnaire = Questionnaire.find(params[:questionnaire_id], :include => [:permissions])
  end
end
