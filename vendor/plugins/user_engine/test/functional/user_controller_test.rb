require File.dirname(__FILE__) + '/../test_helper'
require_dependency 'user_controller'

# Raise errors beyond the default web-based presentation
class UserController; def rescue_action(e) raise e end; end

class UserControllerTest < Test::Unit::TestCase

  fixture :users, :table_name => LoginEngine.config(:user_table), :class_name => 'User'
  fixture :users_roles, :table_name => UserEngine.config(:user_role_table)
  fixture :roles, :table_name => UserEngine.config(:role_table), :class_name => 'Role'
  fixture :permissions_roles, :table_name => UserEngine.config(:permission_role_table)
  fixture :permissions, :table_name => UserEngine.config(:permission_table), :class_name => 'Permission'
  
  def setup
    @controller = UserController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
    @request.host = "localhost"
    # ensure there's no use in each session
    @request.session[:user] = nil
  end

  #==========================================================================
  #
  # Login & Access Control
  #
  #==========================================================================
  
  def test_no_unauthenticated_access
    # make sure that we can't get to 'home'
    assert_nil @request.session[:user]
    get :home
    assert_redirected_to :action => "login"
    assert_match /You need to log in/, flash[:message]    
  end

  def test_login    
    # go to login page - guest should have access
    get :login
    assert_response :success
    
    # now log in
    post :login, :user => {:login => "normal_user", :password => "atest"}
    assert_not_nil @request.session[:user]
    assert_equal @request.session[:user], users(:normal_user)
    
    # we should be sent to home
    assert_redirected_to :action => 'home'
  end
  
  def test_unauthorized_access
    login(:normal_user)

    # ensure that we get redirected back to an action we are authorized to access
    @request.env['HTTP_REFERER'] = "http://#{@request.host}/user/home"
    get :edit_user
    # we should be sent BACK
    assert_match /Permission warning/, flash[:message]
    assert_redirected_to "http://#{@request.host}/user/home"
    
    # ensure that if our previous URL is an action we are no longer authorized for
    # we get sent back to the root
    @request.env['HTTP_REFERER'] = "http://#{@request.host}/user/edit_user/3"
    get :edit_user, :id => 1
    # we should be sent BACK to /, since he's not allowed to edit_user at all.
    assert_match /Permission warning/, flash[:message]
    assert_redirected_to "http://#{@request.host}/"    
  end

  def test_admin_authorized
    login(:admin_user)
    
    # try to edit some user
    get :edit_user, :id => 1
    assert_response :success
  end

  #==========================================================================
  #
  # Create New User
  #
  #==========================================================================

  def test_new_user
    login(:admin_user)

    # create the new user
    post :new, :user => {:login => 'newuser', :password => 'password', 
                         :password_confirmation => 'password', :email => 'newuser@test.com'}

    assert_redirected_to :action => 'list'
    assert_match /User creation successful/, flash[:notice]
    
    # ensure that the user is present
    assert_not_nil User.find_by_login('newuser')
  end

  
  #==========================================================================
  #
  # Show
  #
  #==========================================================================
  def test_show_user
    login(:admin_user)
    
    get :show, :id => users(:normal_user).id
    assert_response :success
    
    get :show, :id => 1231651161
    assert_redirected_to :action => 'list'
    assert_match /There is no user with ID/, flash[:message]    
  
    get :show
    assert_redirected_to :action => 'list'
    assert_match /There is no user with ID/, flash[:message]
  end  
  
  
  #==========================================================================
  #
  # Delete User
  #
  #==========================================================================
  
  def test_delete_user_no_delay
    LoginEngine::CONFIG[:delayed_delete] = false
    login(:admin_user)
    
    post :delete_user, :id => users(:another_user).id
    assert_nil User.find_by_login('another_user')
    assert_redirected_to :action => 'list'
  end
  
  def test_delete_user_with_delay
    LoginEngine::CONFIG[:delayed_delete] = true
    login(:admin_user)
    
    post :delete_user, :id => users(:another_user).id
    assert_equal true, User.find_by_login('another_user').deleted?   
    assert_redirected_to :action => 'list'
  end
  
  
  #==========================================================================
  #
  # Change Password For User
  #
  #==========================================================================

  def test_change_valid_password_for_user
    login(:admin_user)    
    LoginEngine::CONFIG[:use_email_notification] = true
    
    ActionMailer::Base.deliveries = []

    @request.env['HTTP_REFERER'] = "http://#{@request.host}/user/edit_user/#{users(:normal_user).id}"     
    post :change_password_for_user, :id => users(:normal_user).id, 
         :user => { :password => "changed_password", :password_confirmation => "changed_password" }
    
    assert_equal 1, ActionMailer::Base.deliveries.size
    mail = ActionMailer::Base.deliveries[0]
    assert_equal "normal_user@company.com", mail.to_addrs[0].to_s
    assert_match /login:\s+\w+\n/, mail.encoded
    assert_match /password:\s+\w+\n/, mail.encoded
    assert_redirected_to "http://#{@request.host}/user/edit_user/#{users(:normal_user).id}" 

    post :login, :user => { :login => "normal_user", :password => "changed_password" }
    assert_session_has :user
  end

  def test_change_valid_password_for_user_without_email
    login(:admin_user)    
    LoginEngine::CONFIG[:use_email_notification] = false
    
    @request.env['HTTP_REFERER'] = "http://#{@request.host}/user/edit_user/#{users(:normal_user).id}" 
    post :change_password_for_user, :id => users(:normal_user).id,
         :user => { :password => "changed_password", :password_confirmation => "changed_password" }
    
    assert_redirected_to "http://#{@request.host}/user/edit_user/#{users(:normal_user).id}" 

    post :login, :user => { :login => "normal_user", :password => "changed_password" }
    assert_session_has :user
  end

  def test_change_short_password_for_user
    login(:admin_user)
    LoginEngine::CONFIG[:use_email_notification] = true
    ActionMailer::Base.deliveries = []

    @request.env['HTTP_REFERER'] = "http://#{@request.host}/user/edit_user/#{users(:normal_user).id}" 
    post :change_password_for_user, :id => users(:normal_user).id, 
         :user => { :password => "bad", :password_confirmation => "bad" }
         
    assert_invalid_column_on_record "user", "password"
    assert_equal 0, ActionMailer::Base.deliveries.size    
    assert_redirected_to "http://#{@request.host}/user/edit_user/#{users(:normal_user).id}" 

    post :login, :user => { :login => "normal_user", :password => "atest" }
    assert_session_has :user
  end
  
  def test_change_short_password_for_user_without_email
    login(:admin_user)
    LoginEngine::CONFIG[:use_email_notification] = false

    @request.env['HTTP_REFERER'] = "http://#{@request.host}/user/edit_user/#{users(:normal_user).id}"    
    post :change_password_for_user, :id => users(:normal_user).id, 
         :user => { :password => "bad", :password_confirmation => "bad" }
         
    assert_invalid_column_on_record "user", "password"
    assert_redirected_to "http://#{@request.host}/user/edit_user/#{users(:normal_user).id}" 

    post :login, :user => { :login => "normal_user", :password => "atest" }
    assert_session_has :user
  end


  def test_change_password_for_user_with_bad_email
    login(:admin_user)
    LoginEngine::CONFIG[:use_email_notification] = true
    ActionMailer::Base.deliveries = []
    
    get :edit_user, :id => users(:normal_user).id

    # change the password, but the email delivery will fail
    ActionMailer::Base.inject_one_error = true
    post :change_password_for_user, :id => users(:normal_user).id, 
         :user => { :password => "changed_password", :password_confirmation => "changed_password" }
    assert_equal 0, ActionMailer::Base.deliveries.size
    assert_match /Password could not be changed/, flash[:warning]
    
    # ensure we can log in with our original password
    post :login, :user => { :login => "normal_user", :password => "atest" }
    assert_session_has :user
  end  
end
