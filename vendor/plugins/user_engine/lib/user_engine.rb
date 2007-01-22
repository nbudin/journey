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



require 'user_engine/authorized_user'
require 'user_engine/authorized_system'

module UserEngine

  #--
  # These are the default constants, used if nothing else is specified
  #++
  
  # The names of the new Role and Permission tables
  if ActiveRecord::Base.pluralize_table_names
    config :role_table, "roles"
    config :permission_table, "permissions"
  else
    config :role_table, "role"
    config :permission_table, "permission"
  end

  # Join tables for users <-> roles, and roles <-> permissions
  config :user_role_table, "#{LoginEngine.config(:user_table)}_#{config(:role_table)}"
  config :permission_role_table, "#{config(:permission_table)}_#{config(:role_table)}"

  # The names of the Guest and User roles
  # The Guest role is automatically assigned to any visitor who is not logged in
  config :guest_role_name, "Guest"
  # The User role is given to every user
  config :user_role_name, "User"

  # The details for the Admin user and role
  config :admin_role_name, "Admin"
  config :admin_login, "admin"
  config :admin_password, "testing"
  config :admin_email, "admin@your.company"

  # The controller/action
  config :login_page, {:controller => 'user', :action => 'login'}
  
  # If this is set to true, authorization failure messages won't volunteer
  # any extra information, and missing actions will not be flagged as such.
  config :stealth, false
  
  
  
  def self.included(base)

    # we have some specific stuff that we *only* want added to the
    # application controller.
    if base == ApplicationController
      base.class_eval { include UserEngine::AuthorizedSystem }
    end
  end

  # This method will check the Roles in the database against to ensure that there is
  # only ONE omnipotent role.
  def self.check_system_roles
    begin
      if Role.count() > 0
        begin
          omnipotent_roles = Role.find_all_by_omnipotent(true)
          if omnipotent_roles && omnipotent_roles.length != 1
            @warning = "WARNING: You have more than one omnipotent role: " + 
                       omnipotent_roles.collect { |r| r.name }.join(", ")
          elsif omnipotent_roles == nil
            @warning = "WARNING: You have no omnipotent roles. Please re-run the bootstrap rake task."
          end
        rescue
          @warning = "WARNING: Could not check integrity of system roles. Please check your data."
        end
      else
        raise "skip error" # this will be caught below
      end
    rescue # either Roles.count() == 0, or the Roles table doesn't even exist yet.
      @warning = "Skipping integrity check. You have no system roles set up; once your " +
                 "database tables are set up, run rake bootstrap to create the basic roles."             
    end
    
    if @warning != nil
      RAILS_DEFAULT_LOGGER.warn @warning
      puts @warning
    end
  end

  #--
  # The methods to be included in both ApplicationController and ApplicationHelper
  #++
  
  # Returns an HTML link if the user has authorisation to perform the
  # supplied action. All other options and parameters are identical to
  # those for ActionView::link_to
  # e.g.
  #   link_if_authorized("Home", {:controller => "home", :action => "index"})
  #
  # If either of the :controller or :action options are ommitted, the
  # current controller or action will be used instead.
  #
  # This method can also take an additional block, which can override the actual
  # user permissions (i.e. the user must have valid permissions AND this block
  # must not return false or nil for the link to be generated).
  #
  # We also provide special elements with the html_options argument.
  #
  # === :wrap_in
  # This can be used to wrap the link in a given tag. This is useful if some 
  # surrounding markup to the link should also be ommitted if the user is not 
  # authorised for that link. E.g.
  #   <ul>
  #     <%= link_if_authorised("Delete", {:action => "delete"}, :wrap_in => "li") %>
  #     ...
  #   </ul>
  #
  # In this case, if the user is not authorised for this link, the <li></li>
  # element will not be generated. Please note that this is fairly simplistic
  # and relies on Rails' own #content_tag method. For more sophisticated
  # control of markup based on authorisation, use the #authorised?() method
  # directly.
  #
  # === :show_text
  # if this flag is set to true, the text given for the link will be shown
  # (although not as a link) even if the use is NOT authorised for the given
  # action.
  def link_if_authorized(name, options = {}, html_options = {}, *params, &block)
    
    result = html_options.delete(:show_text) ? name : ""
    
    # we need to strip leading slashes when checking authorisation, but not when
    # actually generating the link.
    auth_options = options.dup
    if auth_options[:controller]
      auth_options[:controller] = auth_options[:controller].gsub(/^\//, '')
    end
    
    (block.nil? || (yield block)) && authorized?(auth_options) {
      #result = link_to_with_current_styling(name, options, html_options, *params)
      result = link_to(name, options, html_options, *params)
      
      # TODO: won't this pass other things like html_options[:id], which is EVIL since two
      # things shouldn't share the same ID.
      wrap_tag = html_options.delete(:wrap_in)
      result = content_tag(wrap_tag, result, html_options) if wrap_tag != nil
    }
    result
  end
  

  # Returns true, and also executes an optional code block if the current user 
  # is authorised for the supplied controller and action. If no action is 
  # supplied, "index" is used by default. Returns false if the user is not
  # authorised.
  # e.g.
  #   <% authorized?("person", "destroy") { %>
  #     <p>You have the power to destroy users! Well done.</p>
  #   <% } %>
  def authorized?(options, &block) # default the action to "index"
    
    controller = options[:controller]
    action = options[:action]
    
    # use the current controller/action if none is given in options
    controller ||= @controller.controller_name   
    action ||= @controller.action_name
    
    if !user?
      RAILS_DEFAULT_LOGGER.debug "checking guest authorisation for #{controller}/#{action}"
      if User.guest_user_authorized?(controller, action)
        yield block if block != nil
        return true
      end
    else
      RAILS_DEFAULT_LOGGER.debug "checking user:#{session[:user].id} authorisation for #{controller}/#{action}"
      if current_user.authorized?(controller, action)
        yield block if block != nil
        return true
      end
    end
    return false
  end
  
  # An exception to be raised when the integrity of the authorization system is
  # threatened.
  class SystemProtectionError < Exception
  end
end
