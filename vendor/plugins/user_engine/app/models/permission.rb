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



# The Permission class is simply a database representation of each
# controller/action pair. The association between a Role and a Permission
# instance indicates that such a Role is authorised to call the
# controller/action pair which that Permission represents.
class Permission < ActiveRecord::Base
  
  set_table_name UserEngine.config(:permission_table)
  has_and_belongs_to_many :roles, :join_table => UserEngine.config(:permission_role_table)

  validates_presence_of :controller, :action

  #--
  # Class methods
  #++
  class << self 
    
    # Ensure that the table has one entry for each controller/action pair
    def synchronize_with_controllers
      # weird hack. otherwise ActiveRecord has no idea about the superclass of any
      # ActionController stuff...
      require RAILS_ROOT + "/app/controllers/application"
    
      # Load all the controller files
      controller_files = Dir[RAILS_ROOT + "/app/controllers/**/*_controller.rb"]
    
      # should we check to see if this is defined? I.E. will this code ever run
      # outside of the framework environment...?
      controller_files += Dir[Engines.config(:root) + "/**/app/controllers/**/*_controller.rb"]
    
      # we need to load all the controllers...
      controller_files.each do |file_name|
        require file_name #if /_controller.rb$/ =~ file_name
      end

      # Find the actions in each of the controllers, 
      ApplicationController.all_controllers.collect do |controller|
        controller.new.action_method_names.each { |action|
          if find_all_by_controller_and_action(controller.controller_path, action).empty?
            self.new(:controller => controller.controller_path, :action => action).save          
          end
        }
      end 
    end

    #--
    # A shorthand alias
    #++
    alias :sync :synchronize_with_controllers
  
  end
  
  # Returns the full path which this Permission object represents
  def path
    [controller, action].join("/")
  end
end
