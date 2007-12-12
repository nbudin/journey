# AeForms

module AeForms
  def ae_form_stylesheet
    <<-END_SRC
<style type="text/css">
form.aeform h1, form.aeform h2, form.aeform h3, form.aeform h4, form.aeform h5, form.aeform h6 {
  clear: both;
}

form.aeform ul.inline {
    list-style-type: none;
    margin: 0;
    padding: 0;
    text-align: right;
    clear: both;
}

form.aeform ul.inline li {
    margin-right: 1em;
    display: inline;
    font-size: 90%;
}

form.aeform p {
    font-size: 90%;
}

form.aeform select, form.aeform label, form.aeform input {
    float: left;
    margin-bottom: 0.3em;
    font-size: 90%;
}

form.aeform label, form.aeform input {
    display: block;
    width: 65%;
}

form.aeform input[type=hidden] {
    display: none;
}

form.aeform input[type=checkbox] {
    display: inline;
    width: 10pt;
    height: 10pt;
    vertical-align: middle;
    float: none;
}

form.aeform input[type=submit], form.aeform input[type=button] {
    display: inline;
    vertical-align: middle;
    float: none;
    width: auto;
    font-size: 90%;
    height: 1.5em;
}

form.aeform label {
    text-align: right;
    width: 25%;
    padding-right: 3%;
}

form.aeform br {
    clear: left;
}

form.aeform fieldset {
  margin-bottom: 0.3em;
  border: none;
  border-top: 1px solid black;
  background-color: #ddd;
}

form.aeform textarea {
    margin-bottom: 0.3em;
    width: 65%;
}

form.aeform legend {
  padding: 1px;
  border: 1px solid black;
  font-weight: bold;
  background-color: #eee;
}
</style>
    END_SRC
  end

  class AeFormBuilder < ActionView::Helpers::FormBuilder
    (field_helpers - %w(check_box radio_button hidden_field) + %w(date_select)).each do |selector|
      src = <<-END_SRC
        def #{selector}(field, options = {})
          label = options[:label] || field.to_s.humanize
          (@template.content_tag("label", label + ":", :for => field) +
            super)
        end
      END_SRC
      class_eval src, __FILE__, __LINE__
    end

    def select(field, choices, options = {})
      label = options[:label] || field.to_s.humanize
      (@template.content_tag("label", label + ":", :for => field) +
        super +
        @template.content_tag("br"))
    end
  end

  def ae_form_for(name, object = nil, options = nil, &proc)
    options = options || {}
    options[:html] = (options[:html] || {}).merge(:class => "aeform")
    form_for(name, object, options.merge(:builder => AeFormBuilder), &proc)
  end
end
