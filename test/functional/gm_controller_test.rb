require File.dirname(__FILE__) + '/../test_helper'
require 'gm_controller'

# Re-raise errors caught by the controller.
class GmController; def rescue_action(e) raise e end; end

class GmControllerTest < Test::Unit::TestCase
  def setup
    @controller = GmController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
