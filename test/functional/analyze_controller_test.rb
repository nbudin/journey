require File.dirname(__FILE__) + '/../test_helper'
require 'analyze_controller'

# Re-raise errors caught by the controller.
class AnalyzeController; def rescue_action(e) raise e end; end

class AnalyzeControllerTest < ActionController::TestCase
  def setup
    @controller = AnalyzeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
