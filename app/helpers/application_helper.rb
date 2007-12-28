require 'journey_questionnaire'

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def question_types
    Journey::Questionnaire::question_types
  end

  def field_types
    Journey::Questionnaire::field_types
  end

  def ellipsize(str, len)
    if str.length > len
      str[0,len-3] + "..."
    else
      str
    end
  end

  def icon_for(record_or_class)
    klass = SimplyHelpful::RecordIdentifier::singular_class_name(record_or_class)
    image_tag "icons/#{klass}.png", :alt => klass.humanize, :class => 'icon'
  end

  def create_form_dom_id(klass)
    "#{dom_id(klass)}_create_form"
  end

  def render_question(question)
    @question = question
    value = ''
    if params[:controller] == "answer"
      answer = Answer.find_answer(@resp, question)
      if answer
        value = answer.value
      else
        value = @question.default_answer
      end
    end
    return render(:partial => "questions/" + question.attributes['type'].tableize.singularize,
                  :locals => { 'value' => value })
  rescue
    return render :inline => "<%= start_question @question %><b>Unknown question type for question #{question.id}</b><%= end_question @question %>"
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
end
