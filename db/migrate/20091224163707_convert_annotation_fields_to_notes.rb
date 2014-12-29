class ConvertAnnotationFieldsToNotes < ActiveRecord::Migration
  class Questions::AnnotationField < Questions::FreeformField
    def self.friendly_name
      "Admin notes"
    end
  end
  
  def self.up
    add_column :responses, :notes, :text
    
    Questionnaire.find_each do |q|
      annotation_fields = q.questions.all.select { |question| question.kind_of? Questions::AnnotationField }
      
      if annotation_fields.length > 0
        say "Converting annotation fields to notes for '#{q.title}'"
        
        q.responses.includes(:answers).find_each do |r|
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
        
        annotation_fields.each do |field|
          field.destroy
        end
      end
    end
  end

  def self.down
    needs_annotation = Questionnaire.includes(:responses).to_a.select do |q|
      q.responses.any? { |r| !r.notes.blank? }
    end
    
    needs_annotation.each do |q|
      say "Creating 'Notes' AnnotationField for '#{q.title}'"
      field = Questions::AnnotationField.new(:caption => "Notes")
      page = q.pages.first || q.pages.create
      page.questions.insert(0, field)
      page.save!
      field.save!
      
      say "Converting response notes to AnnotationField answers for '#{q.title}'"
      q.responses.each do |r|
        next if r.notes.blank?
        
        r.answers.create(:question => field, :value => r.notes)
      end
    end
    
    remove_column :responses, :notes
  end
end
