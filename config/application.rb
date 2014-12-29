# Put this in config/application.rb
require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Journey
  class Application < Rails::Application
    config.autoload_paths += [config.root.join('lib')]
    config.encoding = 'utf-8'
    # Settings in config/environments/* take precedence those specified here
        
    # Use Active Record's schema dumper instead of SQL when creating the test database
    # (enables use of different database adapters for development and test environments)
    config.active_record.schema_format = :ruby
    
    config.action_view.sanitized_allowed_attributes = ['id', 'class', 'style']
    
    # Don't let rails-api remove all the default middleware
    config.api_only = false
    
    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.initialize_on_precompile = false
    config.assets.precompile += ["questionnaire_edit/questionnaire_edit.js"]
    
    config.i18n.enforce_available_locales = true
    
    config.generators do |g|
      g.test_framework :mini_test, :spec => true, :fixture => false
    end
    
    config.autoload_paths += %W(#{config.root}/app/exporters)
  
  #  config.middleware.use(Rack::Cache) do
  #    import 'config/rack_cache_config'
  #  end
  end
end
