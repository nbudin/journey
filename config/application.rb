# Put this in config/application.rb
require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Journey
  class Application < Rails::Application
    config.autoload_paths += [config.root.join('lib')]
    config.encoding = 'utf-8'
    # Settings in config/environments/* take precedence those specified here

    # Use Active Record's schema dumper instead of SQL when creating the test database
    # (enables use of different database adapters for development and test environments)
    config.active_record.schema_format = :ruby

    config.action_view.sanitized_allowed_attributes = ['id', 'class', 'style']

    config.rack_cas.server_url = "/cas" # will be replaced in illyan_client initializer
    config.rack_cas.service = "/people/service"

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.initialize_on_precompile = false

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
