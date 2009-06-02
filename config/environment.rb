# Be sure to restart your web server when you modify this file.

RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

#gem 'rack-cache'
#require 'rack/cache'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  config.action_controller.session = {
      :key         => '_journey_aegames_org-trunk_session',
      :secret      => 'ca837e0d9bfed2129139ac1712cf768687981f043aca55c15b424d1deee830babca9bf84afea63d9fd18164f9b026b5c5846b3cb1d64d8febeab9618d24a385f'
    }
      
  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  config.active_record.schema_format = :ruby

  config.gem 'paginator'
  config.gem 'fastercsv'
  config.gem 'mislav-will_paginate', :version => '~> 2.3.2', :lib => 'will_paginate', 
    :source => 'http://gems.github.com'
  
  config.action_view.sanitized_allowed_attributes = ['id', 'class', 'style']

#  config.middleware.use(Rack::Cache) do
#    import 'config/rack_cache_config'
#  end
end
