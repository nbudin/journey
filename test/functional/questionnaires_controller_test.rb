require File.dirname(__FILE__) + '/../test_helper'
require 'questionnaires_controller'

# Re-raise errors caught by the controller.
class QuestionnairesController; def rescue_action(e) raise e end; end

class QuestionnairesControllerTest < ActionController::TestCase
  fixtures :questionnaires

  def setup
    @controller = QuestionnairesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @request[:person] = Person.find(:first).id
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:questionnaires)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_questionnaire
    old_count = Questionnaire.count
    post :create, :questionnaire => { :title => "New questionnaire!" }
    assert_equal old_count+1, Questionnaire.count
    
    assert_redirected_to questionnaire_path(assigns(:questionnaire))
  end

  def test_should_show_questionnaire
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_questionnaire
    put :update, :id => 1, :questionnaire => { }
    assert_redirected_to questionnaire_path(assigns(:questionnaire))
  end
  
  def test_should_destroy_questionnaire
    old_count = Questionnaire.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Questionnaire.count
    
    assert_redirected_to questionnaires_path
  end
end
