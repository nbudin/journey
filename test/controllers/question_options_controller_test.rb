require 'test_helper'

class QuestionOptionsControllerTest < ActionController::TestCase
  before do
    @person = FactoryGirl.create(:person)
    sign_in @person
    
    @question = FactoryGirl.create(:radio_field)
    @page = @question.page
    @questionnaire = @page.questionnaire
    @questionnaire.questionnaire_permissions.create(:person => @person, :all_permissions => true)
  end

  def test_should_get_index
    get :index, :questionnaire_id => @questionnaire.id, :page_id => @page.id, :question_id => @question.id, :format => :json
    assert_response :success
    assert assigns(:question_options)
  end
  
  def test_should_create_question_option
    old_count = QuestionOption.count
    post :create, :questionnaire_id => @questionnaire.id, :page_id => @page.id, :question_id => @question.id, :question_option => { :option => "blue" }, :format => :json
    assert_equal old_count+1, QuestionOption.count
    
    assert_response :success
  end
  
  describe 'with a question option' do
    before { @question_option = FactoryGirl.create(:question_option, :question => @question) }

    it 'should show question option' do
      get :show, :questionnaire_id => @questionnaire.id, :page_id => @page.id, :question_id => @question.id, :id => @question_option.id, :format => :json
      assert_response :success
    end

    it 'should update question option' do
      put :update, :questionnaire_id => @questionnaire.id, :page_id => @page.id, :question_id => @question.id, :id => @question_option.id, :question_option => { :output_value => 3 }, :format => :json
      assert_equal "3", @question_option.reload.output_value
      assert_response :success
    end
  
    it 'should destroy question option' do
      old_count = QuestionOption.count
      delete :destroy, :questionnaire_id => @questionnaire.id, :page_id => @page.id, :question_id => @question.id, :id => @question_option.id, :format => :json
      assert_equal old_count-1, QuestionOption.count
    
      assert_response :success
    end
  end
end
