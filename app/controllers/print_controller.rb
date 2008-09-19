class PrintController < ApplicationController
  def responses
    redirect_to questionnaire_responses_url(params[:id]) + "/print", :status => :moved_permanently
  end
end
