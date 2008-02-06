require 'rexml/document'

class JqmlController < ApplicationController
  layout "global", :except => :export
  
  def export
    @questionnaire = Questionnaire.find(@params[:id])
    @headers["Content-Disposition"] = "attachment; filename=\"#{@questionnaire.title}.jqml\""
    @headers["Content-Type"] = "application/xml; charset=utf-8"
  end
  
  def import
    if @params[:file]

    end
  end
end
