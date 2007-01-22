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
end
