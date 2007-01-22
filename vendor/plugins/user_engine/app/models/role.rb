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



# The Role class represents an abstract set of allowable behaviours within
# an application. Each Role is associated with a number of Permissions (or
# controller/action objects), and such associations indicate what actions
# users using this application are allowed to perform.
class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :class_name => "User", :join_table => UserEngine.config(:user_role_table)
  has_and_belongs_to_many :permissions, :join_table => UserEngine.config(:permission_role_table)

  validates_length_of :name, :minimum => 3
  validates_uniqueness_of :name
  
  # there can only be one omnipotent role.
  def validate_on_create
    if self.omnipotent? && Role.find_by_omnipotent(true)
      errors.add_to_base("There can only be one omnipotent role.")
    end
  end
  
  set_table_name UserEngine.config(:role_table)
  
  def destroy
    if self.system_role?
      raise UserEngine::SystemProtectionError.new("Cannot destroy a system role " +
              " (#{UserEngine.config(:guest_role_name)}, #{UserEngine.config(:user_role_name)}," +
              " or #{UserEngine.config(:admin_role_name)})")
    else
      super
    end
  end
end
