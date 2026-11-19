# Put this in config/application.rb
require File.expand_path('../boot', __FILE__)

require 'rails'

# The frameworks this app uses.  (rails/all would also load Active Storage, Action Cable, Action Mailbox and
# Action Text, which this app doesn't use; they add routes, including public upload and mail ingress endpoints.)
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
require 'active_job/railtie'
require 'rails/test_unit/railtie'
require 'sprockets/railtie'

Bundler.require(:default, Rails.env) if defined?(Bundler)

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

    config.autoloader = :zeitwerk

    # These lib files are loaded with an explicit require (from initializers) and don't define a constant named
    # after the file (they reopen Journey and Sequel::Model), so Zeitwerk can't autoload them.
    Rails.autoloaders.main.ignore(
      config.root.join('lib', 'journey_questionnaire.rb'),
      config.root.join('lib', 'sequel_ext.rb'),
      config.root.join('lib', 'questionnaires_index_profiler.rb')
    )

    # Rails 4.2 ran ActiveJob jobs (such as deliver_later) inline, and Rails 5 defaults to :async, which
    # runs them on a background thread instead.  There's no job backend here, so keep the old behavior.
    config.active_job.queue_adapter = :inline

    # Rails 6 deprecated the old mail delivery job (used by deliver_later); this is the replacement
    config.action_mailer.delivery_job = "ActionMailer::MailDeliveryJob"

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
