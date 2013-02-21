require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  setup do
    @questionnaire = Factory.create :comprehensive_questionnaire
  end
  
  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:pages)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_page
    old_count = Page.count
    post :create, :page => { }, :questionnaire_id => @questionnaire.id
    assert_equal old_count+1, Page.count
    
    assert_redirected_to page_path(assigns(:page))
  end

  context "with a page" do
    setup do
      @page = @questionnaire.pages.first
    end
    
    def test_should_show_page
      get :show, :id => @page.id, :questionnaire_id => @questionnaire.id
      assert_response :success
    end

    def test_should_get_edit
      get :edit, :id => @page.id, :questionnaire_id => @questionnaire.id
      assert_response :success
    end
  
    def test_should_update_page
      put :update, :id => @page.id, :questionnaire_id => @questionnaire.id, :page => { }
      assert_redirected_to page_path(assigns(:page))
    end
  
    def test_should_destroy_page
      old_count = Page.count
      page = pages(:comprehensive1)
      delete :destroy, :id => @page.id, :questionnaire_id => @questionnaire.id
      assert_equal old_count-1, Page.count
    
      assert_redirected_to pages_path
    end
  end
end
