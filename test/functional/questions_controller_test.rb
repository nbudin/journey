require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase
  before do
    @person = FactoryGirl.create(:person)
    sign_in @person
    
    @page = FactoryGirl.create(:page)
    @questionnaire = @page.questionnaire
    @questionnaire.questionnaire_permissions.create(:person => @person, :all_permissions => true)
  end

  def test_should_get_index
    get :index, :questionnaire_id => @questionnaire.id, :page_id => @page.id, :format => :json
    assert_response :success
    assert assigns(:questions)
  end
  
  def test_should_create_question
    old_count = Question.count
    post :create, :questionnaire_id => @questionnaire.id, :page_id => @page.id, :question => { :type => "Questions::TextField" }, :format => :json
    assert_equal old_count+1, Question.count
    
    assert assigns(:question)
    assert_response :success
  end
  
  describe 'with a question' do
    before do
      @question = FactoryGirl.create(:question, :page => @page)
    end

    it 'should show question' do
      get :show, :questionnaire_id => @questionnaire.id, :page_id => @page.id, :id => @question.id, :format => :json
      assert_response :success
    end

    it 'should edit question' do
      get :edit, :questionnaire_id => @questionnaire.id, :page_id => @page.id, :id => @question.id
      assert_response :success
    end
  
    it 'should update question' do
      put :update, :questionnaire_id => @questionnaire.id, :page_id => @page.id, :id => @question.id, :question => { }
      assert_redirected_to [@questionnaire, @page, assigns(:question)]
    end
  
    it 'should destroy question' do
      old_count = Question.count
      delete :destroy, :questionnaire_id => @questionnaire.id, :page_id => @page.id, :id => @question.id
      assert_equal old_count-1, Question.count
    
      assert_redirected_to [@questionnaire, @page]
    end
  end
end
