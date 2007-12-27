desc 'Set up initial permissions for journey stuff'
task :journey_perms => [:sync_permissions, :create_roles, :create_admin_user] do
  guest = Role.find_by_name(UserEngine.config(:guest_role_name))
  user = Role.find_by_name(UserEngine.config(:user_role_name))
  
  ['index', 'answer', 'validate_answers', 'resume', 'save_session', 'save_answers'].each do |action|
    p = Permission.find_by_controller_and_action('questionnaire', action)
    if not guest.permissions.include? p
      guest.permissions << p
    end
    if not user.permissions.include? p
      user.permissions << p
    end
  end

  p = Permission.find_by_controller_and_action('analyze', 'rss')
  if not guest.permissions.include? p
    guest.permissions << p
  end
  if not user.permissions.include? p
    user.permissions << p
  end
  
  synopsis_perms = SynopsisController.new.action_method_names.collect do |action|
    Permission.find_by_controller_and_action('synopsis', action)
  end
  Role.find_all.each do |role|
    synopsis_perms.each do |perm|
      if not role.permissions.include? perm
        role.permissions << perm
      end
    end
    role.save
  end

  raise "Couldn't save guest role!" if !guest.save
  raise "Couldn't save user role!" if !user.save
  
  if Role.find_by_name('Editor') == nil
    puts "Creating Editor role"
    editor = Role.new
    editor.name = 'Editor'
    editor.description = "GMs and their minions."
  else
    editor = Role.find_by_name('Editor')
  end
  
  perms = []
  perms += Permission.find_all_by_controller('questionnaire') 
  perms += Permission.find_all_by_controller('jqml') 
  perms += Permission.find_all_by_controller('analyze')
  perms += Permission.find_all_by_controller('writing')
  perms.each do |perm|
    if not editor.permissions.include? perm
      editor.permissions << perm
    end
  end
  raise "Couldn't save editor role!" if !editor.save
end
    
#task :bootstrap => [:journey_perms]
