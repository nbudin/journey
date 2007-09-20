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
      :class => record.class.to_s, :rows => 1 }.update(options || {})
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
      :class => record.class.to_s, :rows => 1 }.update(options || {})
    rclass = options[:class]
    outstr = <<-ENDDOC
      <span id="#{rclass.downcase}_#{record.id}_#{field}">
        #{record.send(field)}
      </span>
      #{ image_tag("edit-field.png",
        { :id => "edit_#{rclass.downcase}_#{record.id}_#{field}" }) }
      #{ jipe_editor_for(record, field, options)}
    ENDDOC
  end
end
