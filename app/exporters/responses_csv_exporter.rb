class ResponsesCsvExporter
  attr_reader :questionnaire, :rotate

  def initialize(questionnaire, rotate)
    @questionnaire = questionnaire
    @rotate = rotate
  end

  def each_row
    if rotate
      valid_response_ids = db[:answers].select(:response_id).inner_join(:responses, :id => :response_id).where(:questionnaire_id => questionnaire.id)

      response_metadata = db[:responses].order(:id).where(:id => valid_response_ids).select(:id, :submitted_at, :notes).all
      response_ids = response_metadata.map { |resp| resp[:id] }
      yield ["id"] + response_ids
      yield ["Submitted"] + response_metadata.map { |resp| resp[:submitted_at] }
      yield ["Notes"] + response_metadata.map { |resp| resp[:notes] }

      ds = answers_table.order(Sequel.qualify(:pages, :position), Sequel.qualify(:questions, :position), Sequel.qualify(:responses, :id)).
        select(Sequel.qualify(:answers, :question_id), Sequel.qualify(:questions, :caption), Sequel.qualify(:answers, :response_id), Sequel.qualify(:answers, :value), Sequel.qualify(:question_options, :output_value))

      current_response_index = 0
      current_question_id = 0
      current_row = nil
      ds.each do |db_row|
        if db_row[:question_id] != current_question_id
          yield current_row if current_row
          current_row = [db_row[:caption]]
          current_response_index = 0
          current_question_id = db_row[:question_id]
        end

        current_response_id = response_ids[current_response_index]
        if current_response_id != db_row[:response_id]
          skip_to = response_ids.find_index(db_row[:response_id])
          if skip_to
            (skip_to - current_response_index).times { current_row << "" }
            current_response_index = skip_to
          else
            next
          end
        end

        db_row[:output_value] = nil if db_row[:output_value].blank?
        current_row << (db_row[:output_value] || db_row[:value] || "")
        current_response_index += 1
      end
      yield current_row if current_row
    else
      columns = questionnaire.fields

      header = ["id", "Submitted", "Notes"]
      header += columns.collect { |c| c.caption }
      yield header

      ds = answers_table.order(Sequel.desc(Sequel.qualify(:responses, :id)), Sequel.qualify(:pages, :position), Sequel.qualify(:questions, :position)).
        select(Sequel.qualify(:responses, :id), Sequel.qualify(:responses, :submitted_at), Sequel.qualify(:responses, :notes), Sequel.qualify(:answers, :question_id), Sequel.qualify(:answers, :value), Sequel.qualify(:question_options, :output_value))

      column_ids = columns.map(&:id)
      current_column_index = 0
      current_response_id = 0
      current_row = nil
      ds.each do |db_row|
        if db_row[:id] != current_response_id
          yield current_row if current_row
          current_row = [db_row[:id], db_row[:submitted_at], db_row[:notes]]
          current_column_index = 0
          current_response_id = db_row[:id]
        end

        current_column_id = column_ids[current_column_index]
        if current_column_id != db_row[:question_id]
          skip_to = column_ids.find_index(db_row[:question_id])
          if skip_to
            (skip_to - current_column_index).times { current_row << "" }
            current_column_index = skip_to
          else
            next
          end
        end

        db_row[:output_value] = nil if db_row[:output_value].blank?
        current_row << (db_row[:output_value] || db_row[:value] || "")
        current_column_index += 1
      end
      yield current_row if current_row
    end
  end

  private
  def db
    @db ||= RailsSequel.connect
  end

  def answers_table
    db[:answers].
      inner_join(:responses, :id => :response_id).
      inner_join(:questions, :id => Sequel.qualify(:answers, :question_id)).
      inner_join(:pages, :id => Sequel.qualify(:questions, :page_id)).
      left_join(:question_options, :question_id => Sequel.qualify(:answers, :question_id), :option => Sequel.qualify(:answers, :value)).
      where(Sequel.qualify(:responses, :questionnaire_id) => questionnaire.id)
  end
end
