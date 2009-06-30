require 'journey_questionnaire'

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper  
  def dynamic_stylesheet_link_tag(action, *args)
    stylesheet_link_tag(url_for(:controller => 'stylesheets', :action => action, :format => 'css'), *args)
  end

  def ellipsize(str, len)
    if str.length > len
      str[0,len-3] + "..."
    else
      str
    end
  end
  
  def question_class_template(klass)
    "#{klass.name.demodulize.tableize.singularize}"
  end

  def render_question(question)
    @question = question
    
    value = ''
    if params[:controller] == "answer"
      answer = @resp.answer_for_question(question)
      if answer
        value = answer.value
      else
        value = @question.default_answer
      end
    end
    return render(:partial => "questions/" + question_class_template(question.class), :locals => { :value => value })
  rescue Exception => e
    return render(:inline => "<%= start_question @question %><b>Error rendering #{question.class.name.demodulize} \##{question.id} (#{h e.message})</b><%= end_question @question %>")
  end
  
  def render_answer(question, answer)
    @answer = answer
    @question = question
    value = if answer
      if not @editing
        answer.output_value
      else
        answer.value
      end
    else
      nil
    end
    return render(:partial => "answers/" + question_class_template(question.class), :locals => { :value => value })
  rescue Exception => e
    return "<b>Error rendering answer to #{@question.class.name.demodulize} \##{@question.id} (#{h e.message})</b>"
  end

  def start_question(question, options = {})
    options = {
      :is_radio_group => false,
      :is_display => false,
    }.update(options)
    return render(:partial => 'questions/questionstart', :locals => { :question => question }.update(options))
  end

  def end_question(question, options = {})
    options = {
      :is_radio_group => false,
      :is_display => false,
    }.update(options)
    return render(:partial => 'questions/questionend', :locals => { :question => question }.update(options))
  end
  
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
  
  def question_cycle(question)
    if question.kind_of? Questions::Divider
      reset_cycle("questions")
      return "reset-cycle"
    end
    
    if question.kind_of? Questions::Field
      return cycle("odd", "even", :name => "questions")
    else
      return "ignore-cycle"
    end
  end
end
