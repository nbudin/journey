module ResponsesHelper
  def column_selector_option(caption, id, selected_id, attrs={})
    attrs[:value] = id
    if selected_id and id == selected_id
      attrs[:selected] = "selected"
    end
    
    content_tag(:option, caption, attrs)
  end
  
  def column_selector_header_option(caption)
    column_selector_option(caption, "", nil, :disabled => "disabled",
                           :style => "font-weight: bold; border-bottom: 1px black dotted;")
  end
  
  def column_selector_divider_option
    column_selector_option("", "", nil, :disabled => "disabled")
  end
  
  def column_selector_question_option(question, selected)
    column_selector_option(truncate(question.caption), "question_#{question.id}", selected, 
                           :style => "padding-left: 1em;")
  end
  
  def column_selector_meta_option(caption, id, selected)
    column_selector_option(caption, id, selected, :style => "font-style: italic; padding-left: 1em;")
  end
  
  def column_selector_options(questionnaire, selected)
    options = [column_selector_header_option("General response fields"),
               column_selector_meta_option("Title", "title", selected),
               column_selector_meta_option("Submitted at", "submitted_at", selected),
               column_selector_meta_option("Response ID", "id", selected)]
    questionnaire.pages.each do |page|
      fields = page.fields
      if page.fields.size > 0
        options.push(column_selector_divider_option)
        options.push(column_selector_header_option(truncate(page.title)))
        options += fields.collect do |f|
          column_selector_question_option(f, selected)
        end
      end
    end
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
    
    select_tag("column_#{n}", column_selector_options(@questionnaire, colspec),
      :onChange => "$('response_table_options').submit();")
  end
end
