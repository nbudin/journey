require 'test_helper'

class QuestionnairesControllerTest < ActionController::TestCase
  setup do
    sign_in FactoryGirl.create(:person)
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
  
  context 'with a questionnaire' do
    setup { @questionnaire = FactoryGirl.create(:questionnaire) }

    should 'show questionnaire' do
      get :show, :id => @questionnaire.id
      assert_response :success
    end

    should 'edit questionnaire' do
      get :edit, :id => @questionnaire.id
      assert_response :success
    end
  
    should 'update questionnaire' do
      # update redirects to referer
      @request.env['HTTP_REFERER'] = 'http://example.com'
      
      put :update, :id => @questionnaire.id, :questionnaire => { :title => "blooblah" }
      assert_equal "blooblah", @questionnaire.reload.title
      
      assert_redirected_to 'http://example.com'
    end
  
    should 'destroy questionnaire' do
      old_count = Questionnaire.count
      delete :destroy, :id => @questionnaire.id
      assert_equal old_count-1, Questionnaire.count
    
      assert_redirected_to questionnaires_path
    end
  end
end
