module Journey
  module QuestionnaireExtensions
    # use this method to add functionality to the Questionnaire model using modules
    @@extensions = []
    def self.register_extension(ext)
      @@extensions.push(ext) unless @@extensions.include?(ext)
    end
    
    def self.extensions
      @@extensions.dup
    end
  end
  
  module UserOptions
    @@logged_out_options = []
    @@logged_in_options = []
    
    class UserOption
      attr_reader :caption, :url, :conditional
      
      def initialize(caption, url, options = {})
        @caption = caption
        @url = url
        @conditional = options[:conditional]
      end
    end
    
    def self.add_logged_out_option(caption, url, options = {})
      @@logged_out_options.push(UserOption.new(caption, url, options))
    end
  
    def self.add_logged_in_option(caption, url, options = {})
      @@logged_in_options.push(UserOption.new(caption, url, options))
    end
    
    def self.logged_out_options
      @@logged_out_options.dup
    end
    
    def self.logged_in_options
      @@logged_in_options.dup
    end
  end
end