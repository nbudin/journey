class PagesController < ApplicationController
  perm_options = {:class_name => "Questionnaire", :id_param => "questionnaire_id"}
  require_permission "edit", {:only => [:destroy, :new, :edit, :create, :update, :sort]}.update(perm_options)

  layout "answer"
  before_filter :get_questionnaire

  # GET /pages
  # GET /pages.xml
  def index
    @pages = Page.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.json { render :text => @pages.to_json }
      format.xml  { render :xml => @pages.to_xml }
    end
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    @page = Page.find(params[:id])
    check_forged_path

    respond_to do |format|
      format.html # show.rhtml
      format.json { render :text => @page.to_json }
      format.xml  { render :xml => @page.to_xml }
    end
  end

  # GET /pages/new
  def new
    @page = Page.new
  end

  # GET /pages/1;edit
  def edit
    @page = Page.find(params[:id], :include => {:questions => :special_field_association})
    check_forged_path
  end

  # POST /pages
  # POST /pages.xml
  def create
    p = params[:page] || {}
    p[:questionnaire_id] = @questionnaire.id
    p[:title] ||= "Untitled page"
    @page = Page.new(p)

    respond_to do |format|
      if @page.save
        flash[:notice] = 'Page was successfully created.'
        format.html { redirect_to page_url(@questionnaire, @page) }
        format.xml  { head :created, :location => page_url(@questionnaire, @page, :format => 'xml') }
        format.json { head :created, :location => page_url(@questionnaire, @page, :format => 'json') }
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
    @page = Page.find(params[:id])
    check_forged_path

    respond_to do |format|
      if @page.update_attributes(params[:page])
        flash[:notice] = 'Page was successfully updated.'
        format.json { head :ok }
        format.html { redirect_to page_url(@questionnaire, @page) }
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
    @page = Page.find(params[:id])
    check_forged_path
    @page.destroy

    respond_to do |format|
      format.html { redirect_to pages_url(@questionnaire) }
      format.xml  { head :ok }
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
  def get_questionnaire
    @questionnaire = Questionnaire.find(params[:questionnaire_id])
  end
  
  def check_forged_path
    if @page.questionnaire != @questionnaire
      access_denied "That page ID does not match the questionnaire given."
    end
  end
end
