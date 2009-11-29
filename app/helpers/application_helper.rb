# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper 
  def tag_links(questionnaire)
    questionnaire.tag_names.collect { |t| link_to t, questionnaires_path(:tag => t) }.join(", ")
  end
     
  def page_title
    components = []
    if @page_title
      components << @page_title
    end
    globalnav_items.reject { |name, url| name == "Dashboard" }.reverse.each do |name, url|
      components << name
    end
    components << "Journey"
    components.join(" - ")
  end
  
  # by Rob Biedenharn: http://www.mail-archive.com/rubyonrails-talk@googlegroups.com/msg15305.html
  def image_url(source)
    abs_path = image_path(source)
    unless abs_path =~ /\Ahttp/
      abs_path = "http#{'s' if request.ssl?}://#{request.host_with_port}#{abs_path}"
    end
    abs_path
  end
  
  def globalnav_items
    links = []
    
    if logged_in?
      links << ["Dashboard", dashboard_path]
    end

    if request.path =~ /^\/questionnaires/
      links << ["Surveys", questionnaires_path]
      if @questionnaire and @questionnaire.id
        links << [@questionnaire.title, questionnaire_path(@questionnaire)]
      end
    elsif @globalnav_links
      @globalnav_links.each do |name, url|
        links << [name, url]
      end
    end
    
    links
  end
  
  def globalnav_links
    globalnav_items.collect { |name, url| "<li>#{link_to name, url}</li>" }.join("<li>&raquo;</li>")
  end
end
