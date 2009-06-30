module QuestionAnswerHelper
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
