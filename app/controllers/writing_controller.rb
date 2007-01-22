class WritingController < ApplicationController
  def index
    @projects = Project.find_all
    @project = Project.new
  end
  
  def create_project
    @project = Project.create(params[:project])
    @projects = Project.find_all
    render :action => 'index'
  end
  
  def delete_project
    if params[:confirm]
      Project.destroy(params[:id])
      redirect_to :action => 'index'
    else
      @project = Project.find(params[:id])
    end
  end
end
