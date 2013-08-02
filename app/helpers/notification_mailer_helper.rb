module NotificationMailerHelper
  def text_header(text)
    "#{text}\n#{"-" * text.length}"
  end
  
  def text_table(table_data)
    field_name_length = table_data.map {|row| row.first.length }.max
    table_data.map { |(k, v)| "#{k}: #{" " * (field_name_length - k.length)}#{v}"}.join("\n")
  end
  
  def html_table(table_data)
    content_tag(:table) do
      rows = table_data.map do |(k, v)|
        content_tag(:tr) { content_tag(:th, k, align: "right") + content_tag(:td, v) }
      end
      
      safe_join rows, "\n"
    end
  end
  
  def response_submitted_table_data
    [["Response ID", @resp.id]] + @resp.special_answers.map { |answer| [answer.question.caption, answer.output_value]}
  end
end