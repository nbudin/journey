require File.dirname(__FILE__) + '/../test_helper'
require 'larps_controller'

# Re-raise errors caught by the controller.
class LarpsController; def rescue_action(e) raise e end; end

class LarpsControllerTest < Test::Unit::TestCase
  fixtures :larps

  def setup
    @controller = LarpsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:larps)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_larp
    old_count = Larp.count
    post :create, :larp => { }
    assert_equal old_count+1, Larp.count
    
    assert_redirected_to larp_path(assigns(:larp))
  end

  def test_should_show_larp
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_larp
    put :update, :id => 1, :larp => { }
    assert_redirected_to larp_path(assigns(:larp))
  end
  
  def test_should_destroy_larp
    old_count = Larp.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Larp.count
    
    assert_redirected_to larps_path
  end
end
