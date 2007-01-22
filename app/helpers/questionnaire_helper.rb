module QuestionnaireHelper

  def render_question(question)
    @question = question
    if params[:action] == 'answer'
      @answer = Answer.find_answer(@resp, question)
    end
    return render({:partial => question.attributes['type'].tableize.singularize})
  end
  
  def start_question(question)
    return render :partial => 'questionstart', :locals => { :question => question }
  end

  def end_question(question)
    return render :partial => 'questionend', :locals => { :question => question }
  end
  
end
