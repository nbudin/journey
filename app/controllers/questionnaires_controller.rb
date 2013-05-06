require 'paginator'

class QuestionnairesController < ApplicationController  
  load_resource

  # GET /questionnaires
  # GET /questionnaires.xml
  def index
    p = person_signed_in? ? current_person : nil
    per_page = 12
    conditions = []
    condition_vars = {}
    if params[:title] and params[:title] != ''
      conditions.push("lower(title) like :title")
      condition_vars[:title] ="%#{params[:title].downcase}%"
    end
    
    if !params[:tag].blank?
      conditions << "tags.name = :tag_name"
      condition_vars[:tag_name] = params[:tag]
    end
        
    find_conditions = [conditions.join(" and "), condition_vars]
    find_options = {
      :conditions => [conditions.join(" and "), condition_vars],
      :order => 'questionnaires.id DESC',
      :group => "questionnaires.id",
      :include => {:tags => [], :questionnaire_permissions => [:person]},
      :page => params[:page] || 1,
      :per_page => per_page,
    }
    @questionnaires = Questionnaire.accessible_by(current_ability).paginate(find_options)
    
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
                              :include => { :questionnaire => [:questionnaire_permissions, :tags] },
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
    @cloneable_questionnaires = Questionnaire.accessible_by(current_ability, :edit).all(:order => "id DESC").uniq
  end

  # GET /questionnaires/1;edit
  def edit
  end
  
  # GET /questionnaires/1;customize
  def customize
    authorize! :edit, @questionnaire
  end
  
  # GET /questionnaires/1;export
  def export
    authorize! :edit, @questionnaire
  end
  
  # GET /questionnaires/1;share
  def share
    authorize! :change_permissions, @questionnaire
    @questionnaire.questionnaire_permissions.build
  end
  
  # POST /questionnaires
  # POST /questionnaires.xml
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
        @questionnaire.questionnaire_permissions.create(:person => current_person, :all_permissions => true)
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
    params[:questionnaire].delete(:questionnaire_permission_attributes) unless current_person.can?(:change_permissions, @questionnaire)

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
