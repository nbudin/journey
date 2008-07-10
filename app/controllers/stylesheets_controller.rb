class StylesheetsController < ApplicationController
  #caches_page :ie7hacks, :scaffold, :journey, :questionnaire
  layout nil
  
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
end
