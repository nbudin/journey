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
end
