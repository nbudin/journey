ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
require "capybara/rspec/matchers"
require "minitest/rails/capybara"

Capybara.javascript_driver = :webkit
DatabaseCleaner.strategy = :truncation

# Uncomment for awesome colorful output
require "minitest/pride"

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
  
  def save_and_open_screenshot
    @@screenshot_num ||= 0
    @@screenshot_num += 1
    
    page.driver.save_screenshot "tmp/screenshot-#{@@screenshot_num}.png"
    Launchy.open "tmp/screenshot-#{@@screenshot_num}.png"
  end
end