require File.dirname(__FILE__) + '/../test_helper'
require 'jqml_controller'

# Re-raise errors caught by the controller.
class JQMLController; def rescue_action(e) raise e end; end

class JQMLControllerTest < Test::Unit::TestCase
  def setup
    @controller = JQMLController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
