require File.dirname(__FILE__) + '/../test_helper'
require_dependency 'role_controller'

class RoleController; 
  # we don't want to test authorization here
  skip_before_filter :authorize_action

  # Raise errors beyond the default web-based presentation
  def rescue_action(e) raise e end; 
end

class RoleControllerTest < Test::Unit::TestCase

  fixture :users, :table_name => LoginEngine.config(:user_table), :class_name => 'User'
  fixture :users_roles, :table_name => UserEngine.config(:user_role_table)
  fixture :roles, :table_name => UserEngine.config(:role_table), :class_name => 'Role'
  fixture :permissions_roles, :table_name => UserEngine.config(:permission_role_table)
  fixture :permissions, :table_name => UserEngine.config(:permission_table), :class_name => 'Permission'
  
  def setup    
    @controller = RoleController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
    @request.host = "localhost"
  end


  #==========================================================================
  #
  # New
  #
  #==========================================================================

  def assert_new_role
    get :new
    assert_response :success
    
    # create a new role
    post :new, :role => {:name => 'new_role', :description => 'description'}
    assert_redirected_to :action => 'list'
    assert_not_nil Role.find_by_name('new_role')
    
    # create a role which has the same name as an existing role
    post :new, :role => {:name => roles(:admin_role).name}
    assert_template 'new'
    assert_errors
    assert_invalid_column_on_record 'role', 'name'
    
    # create a role with an empty name
    post :new
    assert_template 'new'
    assert_errors
    assert_invalid_column_on_record 'role', 'name'    
  end
  
  #==========================================================================
  #
  # Show
  #
  #==========================================================================
  def test_show_role
    get :show, :id => roles(:custom_role).id
    assert_response :success
    
    get :show, :id => 1231651161
    assert_redirected_to :action => 'list'
    assert_match /There is no role with ID/, flash[:message]    
  
    get :show
    assert_redirected_to :action => 'list'
    assert_match /There is no role with ID/, flash[:message]
  end  
  

  #==========================================================================
  #
  # Edit
  #
  #==========================================================================

  def test_edit_role
    
    get :edit
    assert_redirected_to :action => 'list' # no ID given
    assert_match /There is no role with ID/, flash[:message]
    
    get :edit, :id => 11146134233 # doesn't exist
    assert_redirected_to :action => 'list' # no ID given
    assert_match /There is no role with ID/, flash[:message]
    
    get :edit, :id => roles(:user_role).id
    assert_response :success
    assert_template 'edit'
    
    # supply junk role information
    post :edit, :id => roles(:user_role).id, :permissions_user => [123412,34563,433532]
    assert_template 'edit'
    assert_match /Permission not found/, flash[:message]
    
    # a successful edit
    post :edit, :id => roles(:user_role).id, :permissions_user => [1, 2, 3, 4, 5]
    assert_redirected_to :action => 'show'
    assert_no_errors
    user_role = Role.find_by_id(roles(:user_role).id)
    [1,2,3,4,5].each { |id|
      assert user_role.permissions.include?(Permission.find(id))
    }
    
    # remove some roles now
    post :edit, :id => roles(:user_role).id, :permissions_user => [1, 3, 4]
    assert_redirected_to :action => 'show'
    assert_no_errors
    user_role = Role.find_by_id(roles(:user_role).id)
    [1,3,4].each { |id|
      assert user_role.permissions.include?(Permission.find(id))
    }
    
    # change the information
    post :edit, :id => roles(:custom_role).id, :role => {:name => 'new_name', :description => 'new_description'}
    assert_no_errors
    role = Role.find_by_id(roles(:custom_role).id)
    assert_not_nil role
    assert_equal 'new_name', role.name
    assert_equal 'new_description', role.description
    
    # try and give the role an empty name
    post :edit, :id => roles(:custom_role).id, :role => {:name => ""}
    assert_errors
    assert_invalid_column_on_record 'role', 'name'
    
    # try and give the role the same name as an existing one
    post :edit, :id => roles(:custom_role).id, :role => {:name => roles(:admin_role).name}
    assert_errors
    assert_invalid_column_on_record 'role', 'name'
  end
  
  #==========================================================================
  #
  # Delete
  #
  #==========================================================================
  
  def test_delete_role
    
    # ensure that GET does nothing.
    get :destroy, :id => roles(:custom_role).id
    assert_not_nil Role.find_by_id(roles(:custom_role).id)
    
    # destroy a role that doesn't exist
    post :destroy, :id => 2311512 # doesn't exist
    assert_redirected_to :action => 'list'
    assert_match /There is no role with ID/, flash[:message]
    
    # destroy a role without even giving an ID
    post :destroy # no ID
    assert_redirected_to :action => 'list'
    assert_match /There is no role with ID/, flash[:message]
    
    # actually destry a real role
    post :destroy, :id => roles(:custom_role).id
    assert_redirected_to :action => 'list'
    assert_match /deleted/, flash[:notice]
    assert_equal [], Role.find_all_by_id(roles(:custom_role).id)
  end
  
  #==========================================================================
  #
  # Protected System Roles
  #
  #==========================================================================
  
  def test_system_role_protection
    [:guest_role, :user_role, :admin_role].each do |name|
      post :destroy, :id => roles(name).id
      assert_redirected_to :action => 'list'
      assert_match /Cannot destroy the system role/, flash[:message]
    end
  end
end
