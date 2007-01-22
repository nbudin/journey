# Copyright (c) 2005 James Adam
#
# This is the MIT license, the license Ruby on Rails itself is licensed 
# under.
#
# Permission is hereby granted, free of charge, to any person obtaining 
# a copy of this software and associated documentation files (the 
# "Software"), to deal in the Software without restriction, including 
# without limitation the rights to use, copy, modify, merge, publish, 
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the 
# following conditions:
#
# The above copyright notice and this permission notice shall be included 
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 



# Methods for manipulating and querying roles from a User object
module UserEngine
  
  # This module defines a number of methods to be included into a User model object and class
  # to enable the manipulation and determination of permissions, based on the relationship of
  # User objects to Roles.
  #
  # To use the UserEngine, you must ensure that this module is included in your User model
  # object., e.g.
  # 
  #   class User < ActiveRecord::Base
  #     include LoginEngine::AuthenticatedUser # to do login stuff
  #     include UserEngine::AuthorizedUser     # to ensure authorization for actions
  #       ...
  #   end
  module AuthorizedUser
  
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval {
        has_and_belongs_to_many :roles, :join_table => UserEngine.config(:user_role_table)
        
        # ensure that all users recieve the 'user' role
        before_create :add_user_role
      }
    end
  
    # This module defines methods to be attached to the User class itself.
    module ClassMethods
  
      # Check if the requested controller/action is available for guest users
      # i.e. anyone who isn't logged in.
      # The 'Guest' user is actually a Role object held my no user. The name of this
      # Role object is defined in UserEngine.config(:guest_role_name), and defaults
      # to "Guest". To control which actions are available to site users who are 
      # *not* logged in, you should modify the permissions for this role.
      def guest_user_authorized?(controller, action="index")
        query = <<-EOS
SELECT DISTINCT #{UserEngine.config(:permission_table)}.* 
FROM #{UserEngine.config(:permission_table)}, #{UserEngine.config(:role_table)}, 
     #{UserEngine.config(:permission_role_table)}
WHERE #{UserEngine.config(:role_table)}.name = :role
AND #{UserEngine.config(:role_table)}.id = #{UserEngine.config(:permission_role_table)}.role_id
AND #{UserEngine.config(:permission_role_table)}.permission_id = #{UserEngine.config(:permission_table)}.id
AND #{UserEngine.config(:permission_table)}.controller = :controller
AND #{UserEngine.config(:permission_table)}.action = :action
EOS

        result = Permission.find_by_sql([query, {:role => UserEngine.config(:guest_role_name), 
                                                 :controller => controller.to_s, :action => action.to_s}])    
  
        return (result != nil) && (!result.empty?)       
      end
    end


    # Returns true if this user is authorised to perform the given action. A
    # user is authorized if one or more of the Roles which this user holds is
    # associated with a Permission object which matches the current controller and
    # action.
    def authorized?(controller, action="index")

      return true if self.admin?

      query = <<-EOS
SELECT DISTINCT #{UserEngine.config(:permission_table)}.* 
FROM #{UserEngine.config(:permission_table)}, #{UserEngine.config(:role_table)}, 
     #{UserEngine.config(:permission_role_table)}, #{UserEngine.config(:user_role_table)},
     #{LoginEngine.config(:user_table)}
WHERE #{LoginEngine.config(:user_table)}.id = :person
AND #{LoginEngine.config(:user_table)}.id = #{UserEngine.config(:user_role_table)}.user_id
AND #{UserEngine.config(:user_role_table)}.role_id = #{UserEngine.config(:role_table)}.id
AND #{UserEngine.config(:role_table)}.id = #{UserEngine.config(:permission_role_table)}.role_id
AND #{UserEngine.config(:permission_role_table)}.permission_id = #{UserEngine.config(:permission_table)}.id
AND #{UserEngine.config(:permission_table)}.controller = :controller
AND #{UserEngine.config(:permission_table)}.action = :action
EOS

      result = Permission.find_by_sql([query, {:person => self.id, 
                                               :controller => controller.to_s, :action => action.to_s}])    

      return (result != nil) && (!result.empty?)   
    end  

    # Returns true if this user is has the 'admin' role
    def admin?()
      roles.each { |r| return true if r.omnipotent? }
      false
    end
    
    private
      # This method is called before a User object is saved to ensure that *all* users are
      # given the default 'user' role. The name of this role is defined in 
      # UserEngine.config(:user_role_name).
      def add_user_role
        user_role = Role.find_by_name(UserEngine.config(:user_role_name))
        if user_role
          self.roles << user_role
        else
          raise "Cannot find user-level role '#{UserEngine.config(:user_role_name)}'!"
        end
      end

  end  
end