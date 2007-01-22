class AddedOmnipotentFlagToRoles < ActiveRecord::Migration
  def self.up
    add_column UserEngine.config(:role_table).to_sym, :omnipotent, :boolean, :default => false, :null => false
    
    # try to convert any existing admin role.
    admin_role = Role.find_by_name(UserEngine.config(:admin_role_name))
    if admin_role
      puts "Converting the admin role '#{UserEngine.config(:admin_role_name)}' to be the sole superuser."
      admin_role.omnipotent = true
      if !admin_role.save
        @warning = "Couldn't convert the admin role: #{admin_role.errors}"
      end
    else
      @warning = "Couldn't find the admin role."
    end
    if @warning
      @warning += "\nIf this is not a migration or test, your authorization data may be corrupt."
      RAILS_DEFAULT_LOGGER.warn @warning
      puts @warning
    end
  end
  
  def self.down
    remove_column UserEngine.config(:role_table).to_sym, :omnipotent
  end
end