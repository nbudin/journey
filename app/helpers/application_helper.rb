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
  
  # by Rob Biedenharn: http://www.mail-archive.com/rubyonrails-talk@googlegroups.com/msg15305.html
  def image_url(source)
    abs_path = image_path(source)
    unless abs_path =~ /\Ahttp/
      abs_path = "http#{'s' if request.ssl?}://#{request.host_with_port}#{abs_path}"
    end
    abs_path
  end
  
  def globalnav_links
    links = []
    
    if logged_in?
      links << link_to("Dashboard", dashboard_path)
    end

    if request.path =~ /^\/questionnaires/
      links << link_to("Surveys", questionnaires_path)
      if @questionnaire
        links << link_to(@questionnaire.title, questionnaire_path(@questionnaire))
      end
    elsif @globalnav_links
      @globalnav_links.each do |name, url|
        links << link_to(name, url)
      end
    end
    
    links.collect { |l| "<li>#{l}</li>" }.join("<li>&raquo;</li>")
  end
end
