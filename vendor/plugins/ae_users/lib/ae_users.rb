# AeUsers
require 'active_record'

module AeUsers
  module Acts
    module Permissioned
      def self.included(base)
        base.extend ClassMethods
      end
    
      module ClassMethods
        def acts_as_permissioned(options = {})
          has_many :permissions, :as => :permissioned, :dependent => :destroy
          
          cattr_accessor :permission_names
          self.permission_names = options[:permission_names] || []
          
          self.permission_names.each do |perm|
            define_method("permit_#{perm}") do |person|
              person.permitted?(self, perm)
            end
          end
          
          extend AeUsers::Acts::Permissioned::SingletonMethods    
          include AeUsers::Acts::Permissioned::InstanceMethods
        end
      end
      
      module SingletonMethods
      end
      
      module InstanceMethods
        def permitted?(person, permission=nil)
          self.send "permit_#{permission}?(user)"
        end
        
        def grant(roles, permissions)
          if not roles.kind_of?(Array)
            roles = [roles]
          end
          
          if not permissions.kind_of?(Array)
            if permissions.nil?
              permissions = self.class.permission_names
            else
              permissions = [permissions]
            end
          end
          
          roles.each do |role|
            permissions.each do |perm|
              existing = Permission.find_by_role_and_permission_type(role, perm)
              
              if not existing
                Permission.create :role => role, :permission_type => perm, :permissioned => self
              end
            end
          end
        end
        
        def revoke(roles, permissions=nil)
          if not roles.kind_of?(Array)
            roles = [roles]
          end
          
          if not permissions.kind_of?(Array)
            if permissions.nil?
              permissions = self.class.permission_names
            else
              permissions = [permissions]
            end
          end
          
          roles.each do |role|
            permissions.each do |perm|
              existing = Permission.find_by_role_and_permission_type(role, perm)
              
              if existing
                existing.destroy
              end
            end
          end
        end
      end
    end
  end
end