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
      
      def eval_conditional(context)
        conditional.call(context)
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
  
  module SiteOptions
    @@site_root_if_logged_out = { :controller => "questionnaires", :action => "index" }
    @@site_root_if_logged_in = { :controller => "questionnaires", :action => "my" }
    @@footer_partial = nil
    
    def self.footer_partial=(partial)
      @@footer_partial = partial
    end
    
    def self.footer_partial
      @@footer_partial
    end
    
    def self.site_root(logged_in)
      if logged_in
        @@site_root_if_logged_in
      else
        @@site_root_if_logged_out
      end
    end

    def self.site_root_if_logged_in=(sr)
      @@site_root_if_logged_out = sr
    end
    
    def self.site_root_if_logged_out=(sr)
      @@site_root_if_logged_out = sr
    end
  end
end