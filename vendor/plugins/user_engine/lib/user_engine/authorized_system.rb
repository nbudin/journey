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


module UserEngine
  
  # This module will be automatically included into the ApplicationController
  # when the UserEngine is included. It defines methods to be used as filters
  # for authorization.
  module AuthorizedSystem
    def self.included(base)

      base.extend(ClassMethods)

      base.class_eval do        
        # We don't want these actions to be exposed to the Permission
        # system synchronisation, so we hide them for all controllers.
        hide_action :require_without_load_path_reloading, :process_test
        hide_action :action_method_names, :wsdl, :deepcopy
        hide_action :readable?, :writable?, :r?, :w?, :authorize_action
        hide_action :store_location, :redirect_back_or_default
        
        # methods from the UserEngine module itself
        hide_action :link_if_authorized, :authorized?, :user_name_if_logged_in
      end
    end

    # methods to be added to the ApplicationController
    module ClassMethods
      
      # Returns an array containing all subclasses of ApplicationController
      def all_controllers
        #ObjectSpace.subclasses_of(ApplicationController)
        subclasses_of(ApplicationController)
      end
    end

    # Returns an array of all action names for this controller
    # (Actually returns the result of ApplicationController#action_methods, which is private)
    def action_method_names
      action_methods
    end


    protected

      # This method will return true if:
      #
      # * The Guest Role is authorized to perform the current action
      # * The currently logged in user is omnipotent
      # * The currently logged in user has permission to perform the current
      #   action.
      #
      # In all other cases, it will return false. This method is a replacement
      # for the +login_required+ method provided by the LoginEngine. If the Guest
      # role does not have permission for the current action, the user will be
      # redirected to the login page (and redirected back to this action upon
      # successful authentication). Users can also authenticate directly via
      # a security token (see LoginEngine for details). 
      def authorize_action
        required_permission = "%s/%s" % [ params["controller"], params["action"] ]
        logger.debug "required_perm is #{required_permission}"

        controller = params["controller"]
        action = params["action"]

        # EVERYONE should be able to get to the root. This might never come up, but
        # better to be safe than sorry. This condition could just as easily be
        # appended to the Guest check below, but it's clearer up here.
        if (controller == nil && action == nil)
          return true
        end

        # if the controller wasn't nil, but the action was, then we want to 
        # set the action to "index" so we can check authentication properly
        action ||= "index"

        # If someone is or can be logged in...
        # calling 'user?' from the LoginEngine will ensure that a User is
        # loaded into the session if possible. It could either be there already
        # or via a user_id and security key
        if user?
          # ... then if that logged user is NOT authorised...

          unless current_user.authorized?(controller, action)
            # YOU... SHALL... NOT... PASS!

            flash[:message] = "Permission warning: You are not authorized for the action '#{required_permission}'." 
          
            # Here we are distinguishing between unauthorized actions and actions which do
            # not exist. It *might* be better to employ a 'steath' technique and simple
            # claim that all nonsense actions are unauthorized too... but that can make it
            # difficult to debug.
            if !UserEngine.config(:stealth)
              if Permission.find_by_controller_and_action(controller, action)

                # This is a real action, but the user is not allowed to perform it.
                allowed_roles = Permission.find_by_controller_and_action(controller, action).roles.collect {|r| r.name}.join(', ')
                your_roles = current_user.roles.collect {|r| r.name}.join(', ')
                flash[:message] << " Allowed Roles: #{allowed_roles}. User '#{current_user.login}' has only the following: #{your_roles}."
            
              else # This wasn't even a real action.
              end
            end

            # Otherwise, just send them back to where they were. If they clicked a link, 
            # we'll have the HTTP_REFERER information. Otherwise we'll use our 'prev_uri'
            # information. If we have nothing, set it to be the root.
            return_uri = request.env['HTTP_REFERER'] || session['prev_uri'] || "/"
            # The user wasn't allowed to perform this action. Try and redirect them somewhere
            # If they are no longer allowed to see the page they came here from, 
            # go back to square one. We need to match the URI against the required permission.
            return_uri = "/" if return_uri =~ /\S*\:\/\/\S*\/#{required_permission}\S*/

            # redirect & return false to indicate that controller action processing should NOT continue.
            redirect_to return_uri
            return false
          end
        else
          
          # noone is or can be logged in...
          unless User.guest_user_authorized?(controller, action)          
            flash[:message] = "You need to log in." 
            store_location
            redirect_to UserEngine.config(:login_page)
            return false
          end
        end          

        # If we get here, the user is either a guest and this action is permitted
        # for guest users, or the user is logged in and the action is permitted by
        # one or more of their associated roles. Let them pass..

        @session["prev_uri"] = @request.request_uri
        return true        
      end
  end
end