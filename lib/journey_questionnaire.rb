module Journey
  module QuestionnaireExtensions
    # use this method to add functionality to the Questionnaire model using modules
    @@extensions ||= []
    def self.register_extension(ext)
      @@extensions.push(ext) unless @@extensions.include?(ext)
    end
    
    def self.extensions
      @@extensions.dup
    end
  end
  
  module Dashboard
    @@left_dashboxes ||= []
    @@right_dashboxes ||= []
        
    def self.add_dashbox(partial, column, where='bottom')
      dashbox_set = case column
      when :left
        @@left_dashboxes
      when :right
        @@right_dashboxes
      end
      
      case where.to_sym
      when :top
        dashbox_set.insert(0, partial)
      when :bottom
        dashbox_set << partial
      end
    end
    
    def self.left_dashboxes
      @@left_dashboxes.dup
    end
    
    def self.right_dashboxes
      @@right_dashboxes.dup
    end
  end
  
  module SiteOptions
    @@site_root_if_logged_out ||= { :controller => "root", :action => "welcome" }
    @@site_root_if_logged_in ||= { :controller => "root", :action => "dashboard" }
    @@footer_partial ||= nil
    @@additional_stylesheets ||= []
    @@prepublish_url_options ||= nil
    
    def self.footer_partial=(partial)
      @@footer_partial = partial
    end
    
    def self.footer_partial
      @@footer_partial
    end

    def self.prepublish?
      !@@prepublish_url_options.nil?
    end
    
    def self.prepublish_url_options=(options)
      @@prepublish_url_options = options
    end
    
    def self.prepublish_url_options(questionnaire)
      @@prepublish_url_options.update(:questionnaire_id => questionnaire.id)
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
    
    def self.additional_stylesheets
      @@additional_stylesheets
    end
    
    def self.add_additional_stylesheet(ss)
      @@additional_stylesheets << ss
    end
  end
end
