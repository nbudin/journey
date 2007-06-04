# Include hook code here

require 'ae_users'

ActiveRecord::Base.send(:include, AeUsers::Acts::Permissioned)