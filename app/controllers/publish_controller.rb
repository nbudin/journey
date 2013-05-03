class PublishController < ApplicationController
  load_resource :questionnaire
  
  def show
    authorize! :edit, @questionnaire
    
    if @questionnaire.is_open
      render :action => "widgets"
    elsif Journey::SiteOptions.prepublish?
      redirect_to Journey::SiteOptions.prepublish_url_options(@questionnaire)
    end
  end
  
  def settings
    authorize! :edit, @questionnaire
  end
end
