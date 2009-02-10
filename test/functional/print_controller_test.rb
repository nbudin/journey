require File.dirname(__FILE__) + '/../test_helper'
require 'print_controller'

# Re-raise errors caught by the controller.
class PrintController; def rescue_action(e) raise e end; end

class PrintControllerTest < ActionController::TestCase
  def setup
    @controller = PrintController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
