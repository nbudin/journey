require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  
  fixture :users, :table_name => LoginEngine.config(:user_table), :class_name => 'User'
  fixture :users_roles, :table_name => UserEngine.config(:user_role_table)
  fixture :roles, :table_name => UserEngine.config(:role_table), :class_name => 'Role'
  fixture :permissions_roles, :table_name => UserEngine.config(:permission_role_table)
  fixture :permissions, :table_name => UserEngine.config(:permission_table), :class_name => 'Permission'
  
  def test_table_name
    assert_equal LoginEngine.config(:user_table), User.table_name
  end

  def test_new_users_get_user_role
    u = User.new(:login => 'noone', :email => 'who@cares.com', 
                 :password => 'nothing', :password_confirmation => 'nothing')
    u.save
    assert u.roles.include?(roles(:user_role))
  end

  def test_admin?
    u = User.new
    u.roles << roles(:admin_role)
    assert u.admin?
    assert users(:admin_user).admin?
    assert !users(:normal_user).admin?
  end
  
  
  def test_guest_user_permissions
    [["user", "login"]].each do |controller, action|
      assert User.guest_user_authorized?(controller, action), "guest user SHOULD be authorised for #{controller}/#{action}"
    end
    [["user","home"],
     ["user","edit"],
     ["user","logout"],
     ["user","edit_user"]].each do |controller, action|
      assert !User.guest_user_authorized?(controller, action), "guest user should NOT authorised for #{controller}/#{action}"
    end
  end
  
  def test_user_permissions
    [["user", "login"], # this should be implicit given that Guest has this permission.
     ["user","home"],
     ["user","edit"],
     ["user","logout"]].each do |controller, action|
      assert users(:normal_user).authorized?(controller, action), "normal user SHOULD be authorised for #{controller}/#{action}"
    end    
    [["user", "edit_user"]].each do |controller, action|
      assert !users(:normal_user).authorized?(controller, action), "normal user should NOT authorised for #{controller}/#{action}"
    end    
  end
  
  def test_admin_permissions
    [["user", "login"],
     ["user","home"],
     ["user","edit"],
     ["user","logout"],
     ["user", "edit_user"]].each do |controller, action|
      assert users(:admin_user).authorized?(controller, action), "admin user SHOULD be authorised for #{controller}/#{action}"
    end    
    
    
  end
end
