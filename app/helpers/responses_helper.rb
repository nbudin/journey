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
               column_selector_meta_option("Notes", "notes", selected),
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
  
  def field_selector(id, fields, multiple=false)
    cur_page = nil
    submit_button = content_tag(:p, button_to_function("Graph &gt;&gt;", "seriesSelected('#{escape_javascript id}')"))
    content_tag(:form, :class => "field_selector", :id => id) do
      selector_html = content_tag(:h3, "Choose questions")
      
      if multiple
        selector_html << content_tag(:p, "Which questions would you like to graph the answers to?  Choose as many as you want from the
                                          list below, then press the \"graph\" button.")
      else
        selector_html << content_tag(:p, "Which question would you like to graph the answers to?  Choose from the list below, then
                                          press the \"graph\" button.")
      end
      
      selector_html << submit_button
      
      selector_html << fields.collect do |field|
        html = ""
                  
        if field.page != cur_page
          html << content_tag(:h4, sanitize(field.page.title))
          cur_page = field.page
        end
        
        html << content_tag(:p, :style => "margin: 0;") do
          field_html = ""
          field_id = "#{id}_#{field.id}"
          
          if multiple
            field_html << check_box_tag(id, field.id, false, :id => field_id)
          else
            field_html << radio_button_tag(id, field.id, false, :id => field_id)
          end
          
          field_html << content_tag(:label, :for => field_id) do
            sanitize(field.caption)
          end
        end
      end.join("\n")
      
      selector_html << submit_button
    end
  end
end
