require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < Test::Unit::TestCase
  
  fixture :users, :table_name => LoginEngine.config(:user_table), :class_name => 'User'
  fixture :users_roles, :table_name => UserEngine.config(:user_role_table)
  fixture :roles, :table_name => UserEngine.config(:role_table), :class_name => 'Role'
  fixture :permissions_roles, :table_name => UserEngine.config(:permission_role_table)
  fixture :permissions, :table_name => UserEngine.config(:permission_table), :class_name => 'Permission'

  def test_table_name
    assert_equal UserEngine.config(:role_table), Role.table_name
  end

  def test_new
    r = Role.new(:name => 'new_role', :description => 'new_description')
    assert r.save
    assert_not_nil Role.find_by_name_and_description('new_role', 'new_description')
    assert !r.omnipotent?
    assert !r.system_role?
    
    r = Role.new(:name => 'new_system_role', :system_role => true)
    assert r.save
    assert_not_nil Role.find_by_name('new_system_role')
    assert !r.omnipotent?
    assert r.system_role?
    
  end

  def test_name_uniqueness
    r = Role.new(:name => roles(:admin_role).name)
    assert !r.save
    assert r.errors['name']
  end
  
  def test_create_new_omnipotent
    r = Role.new(:name => 'whatever', :omnipotent => true)
    assert !r.save
    assert !r.valid?
    
    # remove the existing omnipotent role
    admin = Role.find_by_id(roles(:admin_role).id)
    admin.omnipotent = false
    assert admin.save
    
    # create a new role that IS omnipotent
    r = Role.new(:name => 'whatever', :omnipotent => true)
    assert r.save
    assert r.valid?
  end
  
  def test_system_role_protected
    [:guest_role, :user_role, :admin_role].each do |name|
      role = Role.find_by_id(roles(name).id)
      assert_raise UserEngine::SystemProtectionError do
        role.destroy
      end
    end
  end
  
end
