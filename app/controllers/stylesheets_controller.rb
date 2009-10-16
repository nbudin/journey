class StylesheetsController < ApplicationController
  layout nil
  
  caches_page :ie7hacks, :scaffold, :journey, :questionnaire, :welcome
  
  after_filter do |response|
    response.headers["Cache-Control"] = "public"
  end
  
  def ie7hacks
    respond_to do |format|
      format.css {}
    end
  end
  
  def scaffold
    respond_to do |format|
      format.css {}
    end
  end
  
  def journey
    respond_to do |format|
      format.css {}
    end
  end
  
  def questionnaire
    respond_to do |format|
      format.css {}
    end
  end

  def welcome
    respond_to do |format|
      format.css {}
    end
  end
end
