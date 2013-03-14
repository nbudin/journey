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
    p = person_signed_in? ? current_person : nil
    per_page = 12
    conditions = []
    condition_vars = {}
    joins = [:permissions]
    if params[:title] and params[:title] != ''
      conditions.push("lower(title) like :title")
      condition_vars[:title] ="%#{params[:title].downcase}%"
    end
    
    perm_condition = "(is_open = :is_open and publicly_visible = :publicly_visible)"
    condition_vars.update(:is_open => true, :publicly_visible => true)
    if p
      perm_condition << " or (permissions.person_id = :person_id)"
      condition_vars[:person_id] = p.id
      if p.roles.size > 0
        perm_condition << " or (permissions.role_id in (:role_ids))"
        condition_vars[:role_ids] = p.roles.map(&:id)
      end
    end
    conditions << "(#{perm_condition})"
    
    if !params[:tag].blank?
      joins << :tags
      conditions << "tags.name = :tag_name"
      condition_vars[:tag_name] = params[:tag]
    end
        
    find_conditions = [conditions.join(" and "), condition_vars]
    find_options = {
      :conditions => [conditions.join(" and "), condition_vars],
      :order => 'questionnaires.id DESC',
      :joins => joins,
      :group => "questionnaires.id",
      :include => {:tags => [], :permissions => [:person]},
      :page => params[:page] || 1,
      :per_page => per_page,
    }
    @questionnaires = Questionnaire.paginate(find_options)
    
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
  
  def responses
    unless person_signed_in?
      return redirect_to(:action => 'index')
    end
    
    @responses = Response.all(:conditions => { :person_id => current_person.id }, 
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
        if person_signed_in? and current_person.can?(:edit, @questionnaire)
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
        if person_signed_in? and current_person.can?(:edit, @questionnaire)
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
    
    @roles = current_person.roles
    perm_conds = "permission = 'edit' and (person_id = #{current_person.id}"
    if @roles.length > 0
      perm_conds << " OR role_id IN (#{@roles.collect {|r| r.id}.join(",")})"
    end
    perm_conds << ")"
    
    @cloneable_questionnaires = Questionnaire.all(:order => "id DESC",
                                        :conditions => perm_conds, :joins => :permissions).uniq
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
        flash[:error_messages] = ["There was an error parsing the XML file you uploaded.  Please check to make sure it is a valid Journey survey export."]
        m = ex.message.to_s
        if m.length < 500
          flash[:error_messages] << m
        end
        redirect_to :action => "new"
        return
      end
    elsif params[:commit] == "Import"
      flash[:error_messages] = ["Please specify a file to import."]
      redirect_to :action => "new"
      return
    elsif params[:clone_questionnaire_id]
      @questionnaire = Questionnaire.find(params[:clone_questionnaire_id]).deepclone
      @questionnaire.title = "Copy of #{@questionnaire.title}"
      @questionnaire.is_open = false
    else
      p = params[:questionnaire] || {}
      p[:title] ||= "Untitled questionnaire"
      @questionnaire = Questionnaire.new(p)
    end

    respond_to do |format|
      if @questionnaire.save
        @questionnaire.grant(current_person)
        format.html { redirect_to questionnaire_url(@questionnaire) }
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
        format.html { redirect_to params[:return_to] || :back }
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
      format.json do
        render :json => @questionnaire.unused_special_field_purposes.to_json
      end
    end
  end

  def pagelist
    @questionnaire = Questionnaire.find(params[:id])
    render :partial => 'pagelist', :locals => { :questionnaire => @questionnaire }
  end
end
