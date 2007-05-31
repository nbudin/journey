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
  
  class AeFormBuilder < ActionView::Helpers::FormBuilder
    (field_helpers - %w(check_box radio_button hidden_field)).each do |selector|
      src = <<-END_SRC
        def #{selector}(field, options = {})
          (@template.content_tag("label", field.to_s.humanize + ":", :for => field) +
            super +
            @template.content_tag("br"))
        end
      END_SRC
      class_eval src, __FILE__, __LINE__
    end
  end
  
  def ae_form_for(name, object = nil, options = nil, &proc)
    options = options || {}
    options[:html] = (options[:html] || {}).merge(:class => "aeform")
    form_for(name, object, options.merge(:builder => AeFormBuilder), &proc)
  end
end
