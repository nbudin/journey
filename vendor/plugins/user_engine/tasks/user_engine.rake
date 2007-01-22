desc 'Import the User Engine schema.'
task :import_user_engine_schema => [:import_login_engine_schema, :environment] do
  load "#{Engines.get(:user).root}/db/schema.rb"
end

desc 'Create the default roles/permissions/users'
task :bootstrap => [:sync_permissions, :create_roles, :create_admin_user]

desc 'Add any new controller/action permissions to the authorization database'
task :sync_permissions => :environment do
  Permission.synchronize_with_controllers
end

desc 'Create the administrator super-user'
task :create_admin_user => :environment do
  # Create the administrator user, if needed
  if User.find_by_login(UserEngine.config(:admin_login)) == nil
    puts "Creating admin user '#{UserEngine.config(:admin_login)}'"
    u = User.new
    u.login = UserEngine.config(:admin_login)
    u.firstname = "System"
    u.lastname = "Administrator"
    u.email = UserEngine.config(:admin_email)
    u.change_password UserEngine.config(:admin_password)
    u.verified = 1
    raise "Couldn't save administrator!" if !u.save
  end

  u = User.find_by_login(UserEngine.config(:admin_login))
  if !u.roles.include?(Role.find_by_name(UserEngine.config(:admin_role_name)))
    u.roles << Role.find_by_name(UserEngine.config(:admin_role_name))
  end

  raise "Couldn't save administrator after assigning roles!" if !u.save
end

desc 'Create the default roles'
task :create_roles => :environment do

  # Create the Guest Role
  if Role.find_by_name(UserEngine.config(:guest_role_name)) == nil
    puts "Creating guest role '#{UserEngine.config(:guest_role_name)}'"
    guest = Role.new
    guest.name = UserEngine.config(:guest_role_name)
    guest.description = "Implicit role for all accessors of the site"
    guest.system_role = true
    guest.omnipotent = false
    raise "Couldn't save guest role!" if !guest.save

    guest.permissions << Permission.find_by_controller_and_action('user', 'login')
    guest.permissions << Permission.find_by_controller_and_action('user', 'forgot_password')
    guest.permissions << Permission.find_by_controller_and_action('user', 'signup')

    raise "Couldn't save guest role after setting permissions!" if !guest.save
  end

  @all_action_permissions = Permission.find_all

  # Create the Admin role
  if Role.find_by_name(UserEngine.config(:admin_role_name)) == nil
    puts "Creating admin role '#{UserEngine.config(:admin_role_name)}'"
    admin = Role.new
    admin.name = UserEngine.config(:admin_role_name)
    admin.description = "The system administrator, with REAL ULTIMATE POWER."
    admin.omnipotent = true
    admin.system_role = true
    raise "Couldn't save admin role!" if !admin.save

    @all_action_permissions.each { |permission|
      if !admin.permissions.include?(permission)
        admin.permissions << permission
      end
    }

    raise "Couldn't save admin role after assigning permissions!" if !admin.save
  end

  # Create the User role, if needed
  if Role.find_by_name(UserEngine.config(:user_role_name)) == nil
    puts "Creating user role '#{UserEngine.config(:user_role_name)}'"
    user = Role.new
    user.name = UserEngine.config(:user_role_name)
    user.description = "The default role for all logged-in users"
    user.system_role = true
    user.omnipotent = false
    raise "Couldn't save default user role!" if !user.save

    # all users automatically get the Guest permissions implicitly
    user.permissions << Permission.find_by_controller_and_action('user', 'logout')
    user.permissions << Permission.find_by_controller_and_action('user', 'home')
    user.permissions << Permission.find_by_controller_and_action('user', 'change_password')
    user.permissions << Permission.find_by_controller_and_action('user', 'edit')

    raise "Couldn't save default user role after assigning permissions!" if !user.save
  end
end