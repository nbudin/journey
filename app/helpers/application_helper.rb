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

  def jipe_editor_for(record, field, options = {})
    options = { :external_control => true,
      :class => record.class.to_s,
      :rows => 1}.update(options || {})
    rclass = options[:class]
    outstr = <<-ENDDOC
      <script type="text/javascript">
        new Jipe.InPlaceEditor("#{rclass.downcase}_#{record.id}_#{field}",
          #{rclass}, #{record.id}, #{field.to_json}, {
    ENDDOC
    if options[:external_control]
      outstr += "externalControl: 'edit_#{rclass.downcase}_#{record.id}_#{field}', "
    end
    outstr += "rows: #{options[:rows]}});\n</script>"
    return outstr
  end

  def jipe_editor(record, field, options = {})
    options = { :external_control => true,
      :class => record.class.to_s,
      :rows => 1,
      :editing => true }.update(options || {})
    rclass = options[:class]
    outstr = <<-ENDDOC
      <span id="#{rclass.downcase}_#{record.id}_#{field}">
        #{record.send(field)}
      </span>
    ENDDOC
    if options[:editing]
      outstr += <<-ENDDOC
        #{ options[:external_control] ? image_tag("edit-field.png",
          { :id => "edit_#{rclass.downcase}_#{record.id}_#{field}" }) : "" }
        #{ jipe_editor_for(record, field, options)}
      ENDDOC
    end
    return outstr
  end
  
  def jipe_image_toggle(record, field, true_image, false_image, options = {})
    options = {
      :class => record.class.to_s,
      :on_complete => nil,
    }.update(options || {})
    rclass = options[:class]
    value = record.send(field)
    idprefix = "#{rclass.downcase}_#{record.id}_#{field}"
    
    js_options = {}
    js_options['onComplete'] = options[:on_complete] if options[:on_complete]
    
    outstr = <<-ENDDOC
      #{image_tag true_image, :id => "#{idprefix}_true", 
          :style => (value ? "" : "display: none") }
      #{image_tag false_image, :id => "#{idprefix}_false", 
          :style => (value ? "display: none" : "")}
      <script type="text/javascript">
        new Jipe.ImageToggle("#{idprefix}_true", "#{idprefix}_false",
          #{rclass}, #{record.id}, #{field.to_json},
          #{options_for_javascript js_options});
      </script>
    ENDDOC
    return outstr
  end

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
    return render :partial => "questions/" + question.attributes['type'].tableize.singularize,
                  :locals => { 'value' => value }
  end

  def start_question(question)
    return render :partial => 'questions/questionstart', :locals => { :question => question }
  end

  def end_question(question)
    return render :partial => 'questions/questionend', :locals => { :question => question }
  end
end
