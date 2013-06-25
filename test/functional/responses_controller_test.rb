require 'test_helper'

class ResponsesControllerTest < ActionController::TestCase
  before do
    @questionnaire = FactoryGirl.create(:questionnaire)
    
    @person = FactoryGirl.create(:person)
    @person.questionnaire_permissions.create(questionnaire: @questionnaire, all_permissions: true)
    
    sign_in @person
  end
  
  def test_should_get_index
    get :index, questionnaire_id: @questionnaire.id
    assert_response :success
    assert_not_nil assigns(:responses)
  end

  def test_should_create_response
    assert_difference('Response.count') do
      post :create, questionnaire_id: @questionnaire.id, :response => { }
    end

    assert_redirected_to [@questionnaire, assigns(:response)]
  end
  
  describe "with response" do
    before do
      @resp = FactoryGirl.create(:response, questionnaire: @questionnaire)
    end
  
    it 'should show response' do
      get :show, questionnaire_id: @questionnaire.id, :id => @resp.id
      assert_response :success
    end

    it 'should get edit' do
      get :edit, questionnaire_id: @questionnaire.id, :id => @resp.id
      assert_response :success
    end

    it 'should update response' do
      put :update, questionnaire_id: @questionnaire.id, :id => @resp.id, :response => { }
      assert_redirected_to [@questionnaire, assigns(:response)]
    end

    it 'should destroy response' do
      # destroy redirects to referer
      @request.env['HTTP_REFERER'] = 'http://example.com'
      
      assert_difference('Response.count', -1) do
        delete :destroy, questionnaire_id: @questionnaire.id, :id => @resp.id
      end

      assert_redirected_to 'http://example.com'
    end
  end
end
