module Journey
  module Questionnaire
    def self.decorator_types
      %w{ Label Divider Heading }
    end

    def self.field_types
      %w{ TextField BigTextField RangeField CheckBoxField DropDownField RadioField MultiSelectField }
    end
    
    def self.types_for_sql(types)
      '(' + types.collect { |type| "'#{type}'" }.join(', ') + ')'
    end
    
    def self.question_types
      return decorator_types + field_types
    end
  end
end