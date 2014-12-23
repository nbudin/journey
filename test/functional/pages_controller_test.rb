require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  before do
    @questionnaire = FactoryGirl.create :comprehensive_questionnaire
    @person = FactoryGirl.create :person
    @person.questionnaire_permissions.create(:questionnaire => @questionnaire, :all_permissions => true)
    
    sign_in @person
  end
  
  def test_should_get_index
    get :index, :questionnaire_id => @questionnaire.id, :format => :json
    assert_response :success
    assert assigns(:pages)
  end
  
  def test_should_create_page
    old_count = Page.count
    post :create, :page => { }, :questionnaire_id => @questionnaire.id
    assert_equal old_count+1, Page.count
    
    assert_redirected_to [@questionnaire, assigns(:page)]
  end

  describe "with a page" do
    before do
      @page = @questionnaire.pages.first
    end
    
    it 'should show page' do
      get :show, :id => @page.id, :questionnaire_id => @questionnaire.id, :format => :json
      assert_response :success
    end

    it 'should edit page' do
      get :edit, :id => @page.id, :questionnaire_id => @questionnaire.id
      assert_response :success
    end
  
    it 'should update page' do
      put :update, :id => @page.id, :questionnaire_id => @questionnaire.id, :page => { title: "something else" }
      assert_redirected_to [@questionnaire, assigns(:page)]
      assigns(:page).title.must_equal "something else"
    end
  
    it 'should destroy page' do
      old_count = Page.count
      delete :destroy, :id => @page.id, :questionnaire_id => @questionnaire.id
      assert_equal old_count-1, Page.count
    
      assert_redirected_to [@questionnaire, :pages]
    end
  end
end
