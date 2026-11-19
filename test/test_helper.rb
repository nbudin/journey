ENV["RAILS_ENV"] = "test"

require "simplecov"
SimpleCov.start "rails" do
  add_filter "/test/"
  add_filter "/db/"
  add_filter "/config/"
  add_group "Exporters", "app/exporters"
  add_group "Presenters/Helpers", "app/helpers"
end

require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "capybara/rails"

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  %w(headless disable-gpu window-size=1280,1024).each { |arg| options.add_argument(arg) }

  Capybara::Selenium::Driver.new app, browser: :chrome, options: options
end

if ENV['CHROME']
  Capybara.javascript_driver = :chrome
else
  Capybara.javascript_driver = :headless_chrome
end
DatabaseCleaner.strategy = :truncation

require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

# TODO: JIPE can be kind of slow.  Increasing the wait time to work around it.
Capybara.default_max_wait_time = 5

# Rails 4.2 + Ruby 2.6: recycling the test response raises "ThreadError: already initialized"
# because of MonitorMixin.  Reset the monitor state before re-initializing.
# (Backport of the fix from Rails 5.)  Remove when upgrading past Rails 4.2.
class ActionController::TestResponse < ActionDispatch::TestResponse
  def recycle!
    @mon_mutex_owner_object_id = nil
    @mon_mutex = nil
    initialize
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
end

# Some code (the CSV exporter, graphs) talks to the database through its own Sequel connection,
# which can't see data inside an uncommitted test transaction.  Tests for that code include this
# module to commit their data and clean up by truncation instead.
module NonTransactionalDatabase
  def self.included(base)
    base.use_transactional_fixtures = false
    base.class_eval do
      before { DatabaseCleaner.start }
      teardown { DatabaseCleaner.clean }
    end
  end
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
    # Reset the browser session (and wait for in-flight requests) before truncating the DB,
    # otherwise requests from the previous test can leak into the next one.
    Capybara.reset_sessions!
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
