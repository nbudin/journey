class PagesController < ApplicationController
  load_resource :questionnaire
  load_and_authorize_resource :through => :questionnaire

  layout "answer"

  # GET /pages
  # GET /pages.xml
  def index
    respond_to do |format|
      format.json { render :text => @pages.to_json }
      format.xml  { render :xml => @pages.to_xml }
    end
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    respond_to do |format|
      format.json { render :text => @page.to_json }
      format.xml  { render :xml => @page.to_xml }
    end
  end

  # GET /pages/1;edit
  def edit
  end

  # POST /pages
  # POST /pages.xml
  def create
    @page.title ||= "Untitled page"

    respond_to do |format|
      if @page.save
        flash[:notice] = 'Page was successfully created.'
        format.html { redirect_to [@questionnaire, @page] }
        format.xml  { head :created, :location => polymorphic_url([@questionnaire, @page], :format => 'xml') }
        format.json { head :created, :location => polymorphic_url([@questionnaire, @page], :format => 'json') }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors.to_xml }
        format.json { render :json => @page.errors.to_xml }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    respond_to do |format|
      if @page.update_attributes(page_params)
        flash[:notice] = 'Page was successfully updated.'
        format.json { head :ok }
        format.html { redirect_to [@questionnaire, @page] }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page.errors.to_xml }
        format.json { render :json => @page.errors.to_json }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @page.destroy

    respond_to do |format|
      format.html { redirect_to [@questionnaire, :pages] }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
  
  def sort
    @pages = @questionnaire.pages
    @pages.each do |page|
      page.position = params['pagelist'].index(page.id.to_s) + 1
      page.save
    end
    render :nothing => true
  end
  
  private
  def page_params
    params[:page].try(:permit, :position, :title) || {}
  end
end
