ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'

Capybara.javascript_driver = :webkit
DatabaseCleaner.strategy = :truncation

class ActionController::TestCase
  include Devise::TestHelpers
end

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  include Warden::Test::Helpers
  
  self.use_transactional_fixtures = false
  
  before do
    Warden.test_mode!
    DatabaseCleaner.start
  end
  
  teardown do
    Warden.test_reset!
    Capybara.current_driver = Capybara.default_driver
    DatabaseCleaner.clean
  end
end