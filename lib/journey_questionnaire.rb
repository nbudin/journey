module Journey
  module Questionnaire
    def self.decorator_types
      %w{ Label Divider Heading }
    end

    def self.field_types
      %w{ TextField BigTextField RangeField CheckBoxField DropDownField RadioField AnnotationField }
    end
    
    def self.types_for_sql(types)
      '(' + types.collect { |type| "'#{type}'" }.join(', ') + ')'
    end
    
    def self.question_types
      return decorator_types + field_types
    end
    
    def self.question_class(klass)
      if self.question_types.include?(klass)
        return eval(klass)
      end
    end
  end
end