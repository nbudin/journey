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



# The UserEngine UserController overrides the UserController from the
# LoginEngine to give user management methods (list, edit_user, etc)
class UserController < ApplicationController
  
  # Ensure that these methods CANNOT be called via a GET request
  verify :method => :post, :only => %w(edit_roles change_password_for_user delete_user)

  # Displays a paginated list of Users
  def list
    @content_columns = user_content_columns_to_display    
    @user_pages, @all_users = paginate :user, :per_page => 10        
  end

  # Edit the details of any user. The Role which can perform this will almost certainly also
  # need the following permissions: user/change_password, user/edit, user/edit_roles, user/delete
  def edit_user
    if (@user = find_user(params[:id]))
      @all_roles = Role.find_all.select { |r| r.name != UserEngine.config(:guest_role_name) }
      case request.method
        when :get
        when :post
          @user.attributes = params[:user].delete_if { |k,v| not LoginEngine.config(:changeable_fields).include?(k) }
          if @user.save
            flash.now[:notice] = "Details for user '#{@user.login}' have been updated"
          else
            flash.now[:warning] = "Details could not be updated!"
          end
      end
    else
      redirect_back_or_default :action => 'list'
    end
  end
  
  # Edit the roles for a given User object.
  # A user typically shouldn't be allowed to edit their own roles, since they could
  # assign themselves as Admins and then do anything. Therefore, keep this method
  # locked down as much as possible.
  def edit_roles
    if (@user = find_user(params[:id]))
      begin
        User.transaction(@user) do
        
          roles = params[:user][:roles].collect { |role_id| Role.find(role_id) }
          # add any new roles & remove any missing roles
          roles.each { |role| @user.roles << role if !@user.roles.include?(role) }
          @user.roles.each { |role| @user.roles.delete(role) if !roles.include?(role) }

          @user.save
          flash[:notice] = "Roles updated for user '#{@user.login}'."
        end
      rescue
        flash[:warning] = 'Roles could not be edited at this time. Please retry.'
      ensure
        redirect_to :back
      end
    else
      redirect_back_or_default :action => 'list'
    end
  end
  
  # Change the password of an arbitrary user
  def change_password_for_user
    if (@user = find_user(params[:id]))
      do_change_password_for(@user)
      flash[:notice] = "Password for user '#{@user.login}' has been updated."
    end
    redirect_back_or_default :action => 'list'
  end

  # Delete an arbitrary user
  def delete_user
    if (@user = find_user(params[:id]))
      do_delete_user(@user)
      flash[:notice] = "User '#{@user.login}' has been deleted."
    end
    redirect_to :action => 'list'
  end


  # Display the details for a given user
  def show    
    if (@user = find_user(params[:id]))
      @content_columns = user_content_columns_to_display
    else
      redirect_back_or_default :action => 'list'
    end
  end

  # Create a new User, skipping any verification by email.
  def new
    case request.method
      when :get
        @user = User.new
        render
        return true
      when :post
        @user = User.new(params[:user])
        begin
          User.transaction(@user) do
            @user.new_password = true
            @user.verified = 1 # skip verification, because we are ADMIN!
            if @user.save
              flash[:notice] = 'User creation successful.'
              redirect_to :action => 'list'
            end
          end
        rescue Exception => e
          flash.now[:notice] = nil
          flash.now[:warning] = 'Error creating account: confirmation email not sent'
          logger.error e
        end
    end
  end


  protected
    # A convenience method we can use to control the columns of the User object that
    # we might ever to see, and hide all other ones.
    def user_content_columns_to_display
      # we don't want people to see the passwords (even though they)
      # are hashed up...
      desired_columns = ["salted_password", "salt", "security_token", "token_expiry"]
      User.content_columns.delete_if { |c| desired_columns.include?(c.name) }
    end
    
    # A convenience method to find a User, and add any errors to the flash if
    # the User is not found.
    def find_user(id)
      begin
        User.find(id)
      rescue ActiveRecord::RecordNotFound
        flash[:message] = "There is no user with ID ##{id}"
        nil
      end
    end
end