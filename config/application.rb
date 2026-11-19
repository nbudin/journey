# Put this in config/application.rb
require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env) if defined?(Bundler)

require File.expand_path('../../lib/breach_length_hiding', __FILE__)

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

    # BREACH mitigation (replaces the breach-mitigation-rails gem)
    config.middleware.insert_before Rack::ETag, BreachLengthHiding

    # Rails 4.2 ran ActiveJob jobs (such as deliver_later) inline, and Rails 5 defaults to :async, which
    # runs them on a background thread instead.  There's no job backend here, so keep the old behavior.
    config.active_job.queue_adapter = :inline

    # Rails 5 adds data-disable-with to every submit button.  This app's prototype_ujs disables the button as
    # soon as it's clicked, and browsers don't submit disabled buttons, so the "commit" parameter went missing
    # and every button on the answering form (Next page, Finish later...) acted like "Finish".
    config.action_view.automatically_disable_submit_tag = false

    config.generators do |g|
      g.test_framework :mini_test, :spec => true, :fixture => false
    end

    config.autoload_paths += %W(#{config.root}/app/exporters)

  #  config.middleware.use(Rack::Cache) do
  #    import 'config/rack_cache_config'
  #  end
  end
end
