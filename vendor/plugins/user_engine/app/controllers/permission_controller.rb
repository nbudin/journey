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


# The PermissionController provides methods for manipulating Permission
# objects from the web interface.
class PermissionController < ApplicationController

  # We shouldn't accept GET requests that modify data.
  verify :method => :post, :only => %w(destroy)

  # Will redirect to the list view
  def index
    redirect_to :action => "list"
  end

  # Displays a paginated list of all Permission objects
  def list
    @content_columns = Permission.content_columns
    @permission_pages, @permissions = paginate :permission, :order => 'id', :per_page => 15
  end

  # Displays a single Permission object, by the id given.
  def show
    if (@permission = find_permission(params[:id]))
      @content_columns = Permission.content_columns
    else
      redirect_back_or_default :action => 'list'
    end    
  end

  # Creates a new Permission object. Note that this is not the recommended
  # way of creating Permission objects - instead you should use 
  # Permission.sync to add them automatically from your application
  def new
    case request.method
      when :get
        @permission = Permission.new
      when :post
        @permission = Permission.new(@params[:permission])
        if @permission.save
          flash[:notice] = 'Permission was successfully created.'
          redirect_to :action => 'list'
        else
          render_action 'new'
        end      
    end
  end

  # Edits a Permission object
  def edit
    case request.method
      when :get
        if (@permission = find_permission(params[:id])).nil?
          redirect_back_or_default :action => 'list'
        end
      when :post
        if (@permission = find_permission(params[:id]))
          if @permission.update_attributes(@params[:permission])
            flash[:notice] = 'Permission was successfully updated.'
            redirect_to :action => 'show', :id => @permission
          else
            render_action 'edit'
          end
        else
          redirect_back_or_default :action => 'list'
        end              
    end
  end

  # Destroys a Permission Object
  def destroy
    if (@permission = find_permission(params[:id]))
      @permission.destroy
      flash[:notice] = "Permission '#{@permission.path}' deleted."
      redirect_to :action => 'list'
    else
      redirect_back_or_default :action => 'list'
    end
  end
  
  protected
    # A helper method to find Permission objects by ID, and insert
    # appropriate error messages into the flash if it couldn't be
    # found.
    def find_permission(id)
      begin
        Permission.find(id)
      rescue
        flash[:message] = "There is no permission with ID ##{id}"
        nil
      end
    end
end
