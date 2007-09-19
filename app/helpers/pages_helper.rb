module PagesHelper
  def render_question(question)
    @question = question
    value = ''
    if params[:action] == 'answer'
      answer = Answer.find_answer(@resp, question)
      if answer
        value = answer.value
      else
        value = @question.default_answer
      end
    end
    return render :partial => question.attributes['type'].tableize.singularize,
                  :locals => { 'value' => value }
  end

  def start_question(question)
    return render :partial => 'questionstart', :locals => { :question => question }
  end

  def end_question(question)
    return render :partial => 'questionend', :locals => { :question => question }
  end
end
