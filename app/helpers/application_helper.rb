require 'journey_questionnaire'

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include LoginEngine
  include UserEngine
  
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
end
