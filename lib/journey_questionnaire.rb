module Journey
  module Questionnaire

    
    def self.question_class(klass)
      if self.question_types.include?(klass)
        return eval(klass)
      end
    end
    
    # use this method to add functionality to the Questionnaire model using modules
    @@extensions = []
    def self.register_extension(ext)
      @@extensions.push(ext) unless @@extensions.include?(ext)
    end
    
    def self.extensions
      @@extensions.dup
    end
  end
end