# AeForms

module AeForms
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