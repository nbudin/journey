# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper    
  def page_title
    title = ""
    if @page_title
      title << "#{@page_title} - "
    end
    if @questionnaire
      title << "#{h(@questionnaire.title)} - "
    end
    title << "Journey"
  end
end
