require 'test_helper'
require File.join(File.dirname(__FILE__), 'test_helper')

class ScoutTest < ActiveSupport::TestCase
  include ScoutTestHelpers
  
  def teardown
    Scout.reset!
    Scout::Reporter.reset!
  end
  
  def test_startup_resets_reports
    Scout.reports = {}
    assert_nothing_raised { Scout.start! {} }
    assert_nil Scout.reports
  end
  
  def test_startup_starts_the_reporter_background_thread
    assert_nil Scout::Reporter.runner
    assert_nothing_raised { Scout.start! {} }
    assert_equal Thread, Scout::Reporter.runner.class
    assert Scout::Reporter.runner.alive?
  end
  
  def test_metrics_are_gathered_in_the_report_queue
    Scout.record_metrics(*(runtimes, params, response, options = mocked_request))
    assert !Scout.reports[:actions].empty?
    assert_equal 1, Scout.reports[:actions]["tests/index"][:num_requests]
  end
  
end
