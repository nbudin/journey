class PrintController < ApplicationController
  def responses
    @questionnaire = Questionnaire.find(params[:id])
  end
end
