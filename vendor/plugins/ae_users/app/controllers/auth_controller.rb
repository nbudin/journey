class AuthController < ApplicationController
  def login
    @account = Account.find_by_email_address(params[:email])
    if not @account.nil? and not @account.active
      redirect_to :action => :needs_activation, :account => @account, :email => params[:email]
    elsif not @account.nil? and @account.check_password params[:password]
      session[:account] = @account
      redirect_to @request.env["HTTP_REFERER"]
    else
      flash[:error_messages] = ['Invalid email address or password.']
    end
  end
  
  def forgot
    @account = Account.find_by_email_address(params[:email])
    if not @account.nil?
      @account.generate_password
    else
      flash[:error_messages] = ["There's no account matching that email address.  Please try again, or sign up for an account."]
      redirect_to :action => :forgot_form
    end
  end
  
  def resend_activation
    @account = Account.find params[:account]
    if not @account.nil?
      @account.generate_activation params[:email]
    else
      flash[:error_messages] = ["No account found with ID '#{params[:account]}'!"]
      redirect_to :controller => :main, :action => :index
    end
  end
  
  def logout
    session[:account] = nil
    redirect_to @request.env["HTTP_REFERER"]
  end
end
