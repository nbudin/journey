class CheckoutController < ApplicationController
  before_filter :find_current_checkout
  
  def index
  end
  
  protected
  # idea shamelessly stolen from Collaboa...
  def find_current_checkout
    if params[:project]
      @session[:current_project] = params[:project]
    end
    @current_project = Project.find_by_id(@session[:current_project])
    redirect_to :controller => 'writing' if @current_project.nil?
    @current_checkout = Checkout.find_by_project_id_and_user_id(@current_project.id,
      current_user.id)
    if @current_checkout.nil?
      @current_checkout = Checkout.create(:project => @current_project, :user => current_user)
      if @current_checkout.nil?
        flash[:errors] = ["Error checking out #{@current_project}.name from #{@current.project}.repo"]
        redirect_to :controller => 'writing'
      end
    end
  end
end
