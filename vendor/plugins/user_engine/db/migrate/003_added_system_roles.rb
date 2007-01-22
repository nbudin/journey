class AddedSystemRoles < ActiveRecord::Migration
  def self.up
    add_column UserEngine.config(:role_table).to_sym, :system_role, :boolean, :default => false, :null => false
    
    # try to convert any existing admin role.
    system_roles = [:user_role_name, :admin_role_name, :guest_role_name].collect { |role|
      Role.find_by_name(UserEngine.config(role))
    }.compact

    if !system_roles.empty? 
      puts "Trying to setting system role flags."
      system_roles.each { |role|
        role.system_role = true
        if !role.save
          warning = "Couldn't save Role '#{role.name}': #{role.errors}"
          RAILS_DEFAULT_LOGGER.warn warning
          puts warning
        end
      }
    end
  end
  
  def self.down
    remove_column UserEngine.config(:role_table).to_sym, :system_role
  end
end