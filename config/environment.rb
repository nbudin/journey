# Be sure to restart your web server when you modify this file.

#gem 'rack-cache'
#require 'rack/cache'

require File.join(File.dirname(__FILE__), '..', 'lib', 'journey_questionnaire')

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
      
  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  config.active_record.schema_format = :ruby
  
  config.action_view.sanitized_allowed_attributes = ['id', 'class', 'style']

#  config.middleware.use(Rack::Cache) do
#    import 'config/rack_cache_config'
#  end
end
