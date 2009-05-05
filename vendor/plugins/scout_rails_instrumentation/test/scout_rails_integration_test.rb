require 'test_helper'
require File.join(File.dirname(__FILE__), 'test_helper')

class Member < ActiveRecord::Base; end

class ScoutRailsIntegrationTest < ActiveSupport::TestCase
  include ScoutTestHelpers
  load_schema!
  
  def test_queries_are_recorded_for_metrics
    assert Scout.queries.empty?
    Member.find(:all)
    assert !Scout.queries.empty?
    assert_match "SELECT * FROM \"members\"", Scout.queries.first[1]
  end
  
  # controller-based tests are below
  
end

class ScoutController < ActionController::Base
  def index; render :text => ""; end
  def show; render :text => Member.find(:first).name; end
  def fail; raise; end
end

class ScoutControllerTest < ActionController::TestCase
  include ScoutTestHelpers
  load_schema!
  
  def teardown
    Scout.reset!
    Scout::Reporter.reset!
  end
  
  def test_action_dispatch_ensures_reporter_is_running_in_the_background
    Scout::Reporter.reset!
    assert_nil Scout::Reporter.runner
    get :index
    assert_response :success
    assert !Scout::Reporter.runner.nil?
    assert Scout::Reporter.runner.alive?
  end
  
  def test_successful_action_dispatch_results_in_recorded_metrics
    assert Scout.reports.nil?
    get :index
    assert_response :success
    assert !Scout.reports.nil?
    assert !Scout.reports[:actions]["scout/index"].empty?
  end
  
  def test_failed_action_dispatch_foregoes_metric_gathering
    assert Scout.reports.nil?
    assert_raise(RuntimeError) { get :fail }
    assert Scout.reports.nil?
  end
  
  def test_queries_are_gathered_for_reports_during_action_dispatch
    assert Scout.queries.empty?
    get :show
    assert_response :success
    assert !Scout.queries.empty?
    assert_match "SELECT * FROM \"members\"", Scout.queries.first[1]
  end
  
end
