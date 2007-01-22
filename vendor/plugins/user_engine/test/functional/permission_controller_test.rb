require File.dirname(__FILE__) + '/../test_helper'
require_dependency 'permission_controller'

class PermissionController; 
  # we don't want to test authorization here
  skip_before_filter :authorize_action

  # Raise errors beyond the default web-based presentation
  def rescue_action(e) raise e end; 
end

class PermissionControllerTest < Test::Unit::TestCase

  fixture :permissions, :table_name => UserEngine.config(:permission_table), :class_name => 'Permission'
  
  def setup    
    @controller = PermissionController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
    @request.host = 'localhost'
  end

  #==========================================================================
  #
  # New
  #
  #==========================================================================
  def test_new_permission
    post :new, :permission => {:controller => 'controller', :action => 'action'}
    assert_redirected_to :action => 'list'
    assert_not_nil Permission.find_by_controller_and_action('controller', 'action')
    
    # create a permission with no action
    post :new, :permission => {:controller => 'controller'}
    assert_template 'new'
    assert_errors
    assert_invalid_column_on_record 'permission', 'action'
    
    # create a permission with no controller
    post :new, :permission => {:action => 'action'}
    assert_template 'new'
    assert_errors
    assert_invalid_column_on_record 'permission', 'controller'
    
  end
  
  #==========================================================================
  #
  # Show
  #
  #==========================================================================
  def test_show_permission
    get :show, :id => permissions(:edit_user).id
    assert_response :success
    
    get :show, :id => 1231651161
    assert_redirected_to :action => 'list'
    assert_match /There is no permission with ID/, flash[:message]    
  
    get :show
    assert_redirected_to :action => 'list'
    assert_match /There is no permission with ID/, flash[:message]
  end    

  #==========================================================================
  #
  # Edit
  #
  #==========================================================================
  def test_edit_permission
    get :edit, :id => permissions(:stupid_permission).id
    post :edit, :id => permissions(:stupid_permission).id, 
         :permission => {:controller => 'dumb', :action => 'dumb',
                         :description => 'dumb_description'}
    assert_redirected_to :action => 'show'
    # ensure that all fields were stored.
    assert_not_nil Permission.find_by_controller_and_action_and_description('dumb', 'dumb', 'dumb_description')
    
    get :edit, :id => 123415232
    assert_redirected_to :action => 'list'
    assert_match /There is no permission with ID/, flash[:message]    
  end
  
  #==========================================================================
  #
  # Delete
  #
  #==========================================================================
  def test_delete_permission
    post :destroy, :id => permissions(:stupid_permission).id
    assert_redirected_to :action => 'list'
    assert_match /deleted/, flash[:notice]
    assert_equal [], Permission.find_all_by_id(permissions(:stupid_permission).id)

    # now one that doesn't exist
    post :destroy, :id => 123456789 # doesn't exist
    assert_redirected_to :action => 'list'
    assert_match /There is no permission with ID/, flash[:message]
  end
end
