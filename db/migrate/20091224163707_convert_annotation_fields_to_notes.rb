class ConvertAnnotationFieldsToNotes < ActiveRecord::Migration
  def self.up
    add_column :responses, :notes, :text
    
    Questionnaire.all.each do |q|
      annotation_fields = q.questions.all.select { |question| question.kind_of? Questions::AnnotationField }
      
      if annotation_fields.length > 0
        say "Converting annotation fields to notes for '#{q.title}'"
        
        q.responses(:include => :answers).each do |r|
          if annotation_fields.length == 1
            a = r.answer_for_question(annotation_fields.first)
            r.notes = a && a.value
          else
            field_values = annotation_fields.collect do |f|
              a = r.answer_for_question(f)
              caption = f.caption
              if caption && caption !~ /:$/
                caption << ":"
              end
              "#{caption} #{a && a.value}"
            end
            r.notes = field_values.join("\n\n")
          end
          
          r.save
        end
      end
    end
  end

  def self.down
    
    remove_column :responses, :notes
  end
end
