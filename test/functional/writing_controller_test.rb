require File.dirname(__FILE__) + '/../test_helper'
require 'writing_controller'

# Re-raise errors caught by the controller.
class WritingController; def rescue_action(e) raise e end; end

class WritingControllerTest < Test::Unit::TestCase
  def setup
    @controller = WritingController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
