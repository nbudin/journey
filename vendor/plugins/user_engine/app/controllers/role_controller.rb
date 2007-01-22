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



# The RoleController allows Role objects to be manipulated via the
# web interface
class RoleController < ApplicationController

  # We shouldn't accept GET requests that modify data.
  verify :method => :post, :only => %w(destroy)
  
  # Redirects to the list action
  def index
    redirect_to :action => 'list'
  end

  # Displays a paginated list of Role objects
  def list
    @content_columns = Role.content_columns
    @role_pages, @roles = paginate :role, :per_page => 10
  end

  # Displays a single Role object by given id.
  def show
    if (@role = find_role(params[:id]))
      @content_columns = Role.content_columns
        
      @all_permissions = @role.permissions

      # split it up into controllers
      @all_actions = {}
      @all_permissions.each { |permission|
        @all_actions[permission.controller] ||= []
        @all_actions[permission.controller] << permission
      }
    else
      redirect_back_or_default :action => 'list'
    end
  end

  # Creates a new Role object with the given parameters.
  def new
    case request.method
      when :get
        @role = Role.new
      when :post
        @role = Role.new(params[:role])
        if @role.save
          flash[:notice] = 'Role was successfully created.'
          redirect_to :action => 'list'
        else
          render_action 'new'
        end      
    end
  end
  
  # Edit a Role object
  def edit
    case request.method
      when :get
        if (@role = find_role(params[:id]))
          # load up the controllers
          @all_permissions = Permission.find_all
    
          # split it up into controllers
          @all_actions = {}
          @all_permissions.each { |permission|
            @all_actions[permission.controller] ||= []
            @all_actions[permission.controller] << permission
          }
        else
          redirect_back_or_default :action => 'list'
        end
      when :post
        if (@role = find_role(params[:id]))
          # update the action permissions
          permission_keys = params.keys.select { |k| k =~ /^permissions_/ }
          permissions = permission_keys.collect { |k| params[k] }
          
          begin
            permissions.collect! { |perm_id| Permission.find(perm_id) }
    
            # just wipe them all and re-build
            @role.permissions.clear
    
            permissions.each { |perm|
              if !@role.permissions.include?(perm)
                @role.permissions << perm
              end
            }
            
            # save the object    
            if @role.update_attributes(params[:role])
              flash[:notice] = 'Role was successfully updated.'
              redirect_to :action => 'show', :id => @role
            else
              flash[:message] = 'The role could not be updated.'
              render :action => 'edit'
            end
          rescue ActiveRecord::RecordNotFound => e
            flash[:message] = 'Permission not found!'
            render :action => 'edit'
          end
        else
          redirect_back_or_default :action => 'list'
        end       
    end        
  end

  # Destroy a given Role object
  def destroy
    if (@role = find_role(params[:id]))
      begin
        @role.destroy
        flash[:notice] = "Role '#{@role.name}' has been deleted." 
        redirect_to :action => 'list'
      rescue UserEngine::SystemProtectionError => e
        flash[:message] = "Cannot destroy the system role '#{@role.name}'!"
        redirect_to :action => 'list'
      end
    else
      redirect_back_or_default :action => 'list'
    end
  end
  
  protected
    # A convenience method to find a Role, and add any errors to the flash if
    # the Role is not found.
    def find_role(id)
      begin
        Role.find(id)
      rescue ActiveRecord::RecordNotFound
        flash[:message] = "There is no role with ID ##{id}"
        nil
      end
    end     
end
