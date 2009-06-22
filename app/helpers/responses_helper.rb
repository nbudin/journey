module ResponsesHelper
  def column_selector_option(caption, id, selected_id, attrs={})
    attrs[:value] = id
    if id == selected_id
      attrs[:selected] = "selected"
    end
    
    content_tag(:option, caption, attrs)
  end
  
  def column_selector_options(questionnaire, selected)
    meta_option_style = "font-style: italic;"
    
    options = [column_selector_option("Title", "title", selected, :style => meta_option_style),
               column_selector_option("Submitted at", "submitted_at", selected, :style => meta_option_style)]
    options += questionnaire.fields.collect do |f|
      column_selector_option(truncate(f.caption), "question_#{f.id}", selected)
    end
    options.push(column_selector_option("ID", "id", selected, :style => meta_option_style))
    return options.join("\n")
  end
  
  def column_selector(column, n)
    if column.kind_of? Question
      colspec = "question_#{column.id}"
    elsif column.kind_of? String
      colspec = column
    else
      colspec = column.to_s
    end
    
    select_tag("column_#{n}", column_selector_options(@questionnaire, colspec))
  end
end
