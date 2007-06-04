class AccountController < ApplicationController
  before_filter :check_logged_in, :except => [:activate, :activation_error]
  
  def activate
    if session[:account]
      # already logged into an account
      redirect_to :controller => :main, :action => :index
      return
    end

    @account = Account.find params[:account]

    if not @account.nil? and @account.activation_key == params[:activation_key]
      @account.active = true
      @account.activation_key = nil
      @account.save
    else
      redirect_to :action => :activation_error
    end
  end
  
  def edit_profile
    @person = session[:account].person
    if request.post?
      @person.update_attributes params[:person]
    end
  end
  
  def edit_email_addresses
    account = session[:account]
    errs = []
    
    if params[:new_address] and params[:new_address].length > 0
      existing_ea = EmailAddress.find_by_address params[:new_address]
      if existing_ea
        errs.push "A different account is already associated with the email address you tried to add."
      else
        newea = EmailAddress.create :account => account, :address => params[:new_address]
        if params[:primary] == 'new'
          newea.primary = true
          newea.save
        end
      end
    end
    
    if params[:primary] and params[:primary] != 'new'
      id = params[:primary].to_i
      if id != 0
        addr = EmailAddress.find id
        if addr.account != account
          errs.push "The email address you've selected as primary belongs to a different account."
        else
          addr.primary = true
          addr.save
        end
      else
        errs.push "The email address you've selected as primary doesn't exist."
      end
    end
    
    if params[:delete]
      params[:delete].each do |id|
        addr = EmailAddress.find id
        if addr.account != account
          errs.push "The email address you've selected as primary belongs to a different account."
        elsif addr.primary
          errs.push "You can't delete the primary email address for your account."
        else
          addr.destroy
        end
      end
    end
    
    if errs.length > 0
      flash[:error_messages] = errs
    end
    
    redirect_to :action => :edit_profile
  end
  
  def change_password
    if params[:password1].nil? or params[:password2].nil?
      redirect_to :action => :edit_profile
    elsif params[:password1] != params[:password2]
      flash[:error_messages] = ["The passwords you entered don't match.  Please try again."]
      redirect_to :action => :edit_profile
    else
      session[:account].password = params[:password1]
      session[:account].save
    end
  end
  
  def activation_error
  end
  
  def signup_success
  end
  
  def signup
    @account = Account.new(:password => params[:password1])
    @addr = EmailAddress.new :address => params[:email], :account => @account, :primary => true

    @person = Person.new :account => @account
    @person.attributes = params[:person]
        
    if request.post?
      error_fields = []
      error_messages = []
    
      if Account.find_by_email_address(params[:email])
        error_messages.push "An account at that email address already exists!"
      end
    
      if params[:password1] != params[:password2]
        error_fields += ["password1", "password2"]
        error_messages.push "Passwords do not match."
      elsif params[:password1].length == 0
        error_fields += ["password1", "password2"]
        error_messages.push "You must enter a password."
      end
    
      ["firstname", "lastname", "email", "gender"].each do |field|
        if (not params[field] or params[field].length == 0) and (not params[:person][field] or params[:person][field].length == 0)
          error_fields.push field
          error_messages.push "You must enter a value for #{field}."
        end
      end
      
      if error_fields.size > 0 or error_messages.size > 0
        flash[:error_fields] = error_fields
        flash[:error_messages] = error_messages
      else
        @account.save
        @addr.save
        @person.save
    
        begin
          @account.generate_activation
        rescue
          @account.activation_key = nil
          @account.active = true
          @account.save
          flash[:error_messages] = ["Sorry, but we encountered a problem while trying to send your account "+
            "activation key!  Your account has been set up and, since we couldn't send you your activation, "+
            "it has been made active effective immediately.  Please ignore the message below.  You can simply "+
            "return to the main page and begin signing up for events now."]
        end
      
        redirect_to :action => :signup_success
      end
    end
  end
  
  def check_logged_in
    if not session[:account]
      flash[:error_messages] = ["You're not logged in.  To view the page you were trying to view, you must log in."]
      redirect_to :controller => :main, :action => :index
    end
  end
end
