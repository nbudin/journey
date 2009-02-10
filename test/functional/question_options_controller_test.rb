require File.dirname(__FILE__) + '/../test_helper'
require 'question_options_controller'

# Re-raise errors caught by the controller.
class QuestionOptionsController; def rescue_action(e) raise e end; end

class QuestionOptionsControllerTest < ActionController::TestCase
  fixtures :question_options

  def setup
    @controller = QuestionOptionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:question_options)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_question_option
    old_count = QuestionOption.count
    post :create, :question_option => { }
    assert_equal old_count+1, QuestionOption.count
    
    assert_redirected_to question_option_path(assigns(:question_option))
  end

  def test_should_show_question_option
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_question_option
    put :update, :id => 1, :question_option => { }
    assert_redirected_to question_option_path(assigns(:question_option))
  end
  
  def test_should_destroy_question_option
    old_count = QuestionOption.count
    delete :destroy, :id => 1
    assert_equal old_count-1, QuestionOption.count
    
    assert_redirected_to question_options_path
  end
end
