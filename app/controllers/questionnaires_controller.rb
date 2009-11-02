require 'paginator'

class QuestionnairesController < ApplicationController
  rest_edit_permissions
  uses_tiny_mce :options => {
    :theme => 'advanced',
    :theme_advanced_buttons1 => 'formatselect, bold, italic, underline, strikethrough, |, bullist, numlist, outdent, indent, |, undo, redo, |, link,unlink,image',
    :theme_advanced_buttons2 => '',
    :theme_advanced_buttons3 => '',
    :theme_advanced_toolbar_location => 'top',
    :theme_advanced_toolbar_align => 'left',
    :theme_advanced_resizing => true,
    :theme_advanced_resize_horizontal => false,
    :theme_advanced_statusbar_location => 'bottom',
    :content_css => '/stylesheets/questionnaire.css'
  }

  # GET /questionnaires
  # GET /questionnaires.xml
  def index
    p = logged_in? ? logged_in_person : nil
    per_page = 12
    conditions = []
    condition_vars = {}
    if params[:title] and params[:title] != ''
      conditions.push("lower(title) like :title")
      condition_vars[:title] ="%#{params[:title].downcase}%"
    end
    find_conditions = [conditions.join(" and "), condition_vars]
    all_questionnaires = if params[:tag] and params[:tag] != ''
      t = Tag.find_by_name(params[:tag])
      if t.nil?
        []
      else
        t.questionnaires(:conditions => find_conditions, :order => 'id DESC', :include => [:taggings, :tags, :permissions])
      end
    else
      Questionnaire.all(:conditions => find_conditions, :order => 'id DESC', :include => [:taggings, :tags, :permissions])
    end
    permitted_questionnaires = all_questionnaires.select do |q|
      (q.is_open and q.publicly_visible) or (p and Questionnaire.permission_names.any? { |pn| p.permitted?(q, pn) })
    end
    pager = ::Paginator.new(permitted_questionnaires.size, per_page) do |offset, pp|
      permitted_questionnaires[offset, pp]
    end
    @questionnaires = returning WillPaginate::Collection.new(params[:page] || 1, per_page, permitted_questionnaires.size) do |paginator|
      paginator.replace pager.page(params[:page]).items
    end
    
    @rss_url = questionnaires_url(:format => "rss")

    respond_to do |format|
      format.html { }
      format.rss  { render :layout => false }
      format.js do
        render :update do |page|
          page.replace_html 'questionnaire_list', :partial => 'paged_results'
        end
      end
    end
  end
  
  def my
    redirect_to :action => 'index' unless logged_in?
    
    @roles = logged_in_person.roles
    perm_conds = "(person_id = #{logged_in_person.id}"
    if @roles.length > 0
      perm_conds << " OR role_id IN (#{@roles.collect {|r| r.id}.join(",")})"
    end
    perm_conds << ") AND permissioned_type = 'Questionnaire'"
    
    @questionnaires = Questionnaire.all(:order => "id DESC", :include => [:permissions, :tags], 
                                        :conditions => perm_conds, :joins => :permissions).uniq.select do |q|
      Questionnaire.permission_names.any? { |pn| logged_in_person.permitted?(q, pn) }
    end
  end
  
  def responses
    redirect_to :action => 'index' unless logged_in?
    
    @responses = Response.all(:conditions => { :person_id => logged_in_person.id }, 
                              :include => { :questionnaire => [:permissions, :tags] },
                              :order => "created_at DESC")
    @questionnaires = @responses.collect { |r| r.questionnaire }.uniq
  end

  # GET /questionnaires/1
  # GET /questionnaires/1.xml
  def show
    @questionnaire = Questionnaire.find(params[:id])
    attributes = params[:attributes] || @questionnaire.attribute_names
    attributes.delete "rss_secret"

    respond_to do |format|
      format.html {}
      format.xml do
        if logged_in? and logged_in_person.permitted?(@questionnaire, "edit")
          headers["Content-Disposition"] = "attachment; filename=\"#{@questionnaire.title}.xml\""
          render :xml => @questionnaire.to_xml
        else
          render :text => "You're not allowed to edit this questionnaire.", :status => :forbidden
        end
      end
      format.js do
        render :update do |page|
          page.replace_html "questionnairesummary_#{@questionnaire.id}", :partial => "summary"
        end
      end
      format.json do
        if logged_in? and logged_in_person.permitted?(@questionnaire, "edit")
          render :json => @questionnaire.to_json(:only => attributes)
        else
          render :text => "You're not allowed to edit this questionnaire.", :status => :forbidden
        end
      end
    end
  end
  
  # GET /questionnaires/1;print
  def print
    @questionnaire = Questionnaire.find(params[:id], :include => :pages)
    @resp = Response.new(:questionnaire => @questionnaire)
    
    render :layout => "print"
  end

  # GET /questionnaires/new
  def new
    @questionnaire = Questionnaire.new
  end

  # GET /questionnaires/1;edit
  def edit
    @questionnaire = Questionnaire.find(params[:id], :include => [:permissions, :pages])
  end
  
  require_permission "edit", :only => [:customize, :publish, :export]
  
  # GET /questionnaires/1;customize
  def customize
    @questionnaire = Questionnaire.find(params[:id], :include => [:permissions])
  end
  
  # GET /questionnaires/1;export
  def export
    @questionnaire = Questionnaire.find(params[:id], :include => [:permissions])
  end
  
  # GET /questionnaires/1;share
  def share
    @questionnaire = Questionnaire.find(params[:id], :include => [:permissions])
  end
  
  # POST /questionnaires
  # POST /questionnaires.xml
  require_login :only => [:create]
  def create
    if params[:file]
      begin
        @questionnaire = Questionnaire.from_xml(params[:file].read)
        logger.debug @questionnaire.taggings
      rescue Exception => ex
        flash[:error_messages] = ["There was an error parsing the JQML file you uploaded.  Please check to make sure it is a valid JQML file."]
        m = ex.message.to_s
        if m.length < 500
          flash[:error_messages] << m
        end
        redirect_to :action => "index"
        return
      end
    else
      p = params[:questionnaire] || {}
      p[:title] ||= "Untitled questionnaire"
      @questionnaire = Questionnaire.new(p)
    end

    respond_to do |format|
      if @questionnaire.save
        @questionnaire.grant(logged_in_person)
        format.html { redirect_to questionnaires_url }
        format.xml  { head :created, :location => questionnaire_url(@questionnaire) }
      else
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @questionnaire.errors.to_xml }
      end
    end
  end

  # PUT /questionnaires/1
  # PUT /questionnaires/1.xml
  def update
    @questionnaire = Questionnaire.find(params[:id])

    respond_to do |format|
      if @questionnaire.update_attributes(params[:questionnaire])
        format.html { redirect_to :back }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html do
          flash[:error_messages] = @questionnaire.errors.full_messages
          redirect_to :back 
        end
        format.xml  { render :xml => @questionnaire.errors.to_xml }
        format.json { render :json => @questionnaire.errors.to_json }
      end
    end
  end

  # DELETE /questionnaires/1
  # DELETE /questionnaires/1.xml
  def destroy
    @questionnaire = Questionnaire.find(params[:id])
    @questionnaire.destroy

    respond_to do |format|
      format.html { redirect_to questionnaires_url }
      format.xml  { head :ok }
    end
  end
  
  def available_special_field_purposes
    @questionnaire = Questionnaire.find(params[:id])
    
    respond_to do |format|
      format.xml do
        xml = Builder::XmlMarkup.new(:indent => 2)
        xml.instruct!
        render :xml => (xml.available_purposes do
          @questionnaire.unused_special_field_purposes.each do |p|
            xml.purpose p
          end
        end)
      end
    end
  end

  def pagelist
    @questionnaire = Questionnaire.find(params[:id])
    render :partial => 'pagelist', :locals => { :questionnaire => @questionnaire }
  end
end
