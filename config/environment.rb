# Be sure to restart your web server when you modify this file.

RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
ENV['RAILS_ENV'] ||= 'production'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  config.action_controller.session = {
      :session_key => '_journey_aegames_org-trunk_session',
      :secret      => 'ca837e0d9bfed2129139ac1712cf768687981f043aca55c15b424d1deee830babca9bf84afea63d9fd18164f9b026b5c5846b3cb1d64d8febeab9618d24a385f'
    }
      
  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  config.active_record.schema_format = :ruby

  config.gem 'mislav-will_paginate', :version => '~> 2.3.2', :lib => 'will_paginate', 
    :source => 'http://gems.github.com'
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

#Mime::Type.register("text/css", :css)

# Set up the workdir, make sure it exists
JOURNEY_WORKDIR = File.join(File.expand_path(RAILS_ROOT), "working_copies")
FileUtils.mkdir_p JOURNEY_WORKDIR
