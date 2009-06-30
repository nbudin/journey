module TabstripHelper
  def link_tab_class(action)
    if params[:action] == action
      'selected_link'
    else
      'link'
    end
  end
  
  def toplevel_link_tab_class(ctrlr, options={})
    if params[:controller] == ctrlr
      if options[:except].nil? or (not options[:except].include?(params[:action]))
        if options[:only].nil? or (options[:only].include?(params[:action]))
          return 'selected_link'
        end
      end
    end
    return 'link'
  end
  
  def tabstrip_li(caption, url, options={})
    level = options.delete(:level) || 1
    classes = []
    classes.push(options.delete(:class) || 'link')
    
    if level == 1
      ctrlr = options.delete :controller
      if params[:controller] == ctrlr
        except = options.delete :except
        if except.nil? or (not except.include?(params[:action]))
          only = options.delete :only
          if only.nil? or (only.include?(params[:action]))
            classes.push 'selected'
          end
        end
      end
    elsif level == 2
      if params[:action] == options.delete(:action)
        classes.push 'selected'
      end
    end
    
    if options.delete(:disabled)
      classes.push 'disabled'
    end
    
    content_tag("li", options.update(:class => classes.join(" "))) do
      if classes.include? 'disabled' or classes.include? 'selected'
        url = "#"
      end
      link_to(caption, url)
    end
  end
end