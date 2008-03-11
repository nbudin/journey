require File.dirname(__FILE__) + '/../test_helper'

class ResponsesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:responses)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_response
    assert_difference('Response.count') do
      post :create, :response => { }
    end

    assert_redirected_to response_path(assigns(:response))
  end

  def test_should_show_response
    get :show, :id => responses(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => responses(:one).id
    assert_response :success
  end

  def test_should_update_response
    put :update, :id => responses(:one).id, :response => { }
    assert_redirected_to response_path(assigns(:response))
  end

  def test_should_destroy_response
    assert_difference('Response.count', -1) do
      delete :destroy, :id => responses(:one).id
    end

    assert_redirected_to responses_path
  end
end
