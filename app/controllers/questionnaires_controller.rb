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
        
    questionnaire_scope = Questionnaire.accessible_by(current_ability).
      order(id: :desc).
      group("questionnaires.id").
      includes(:tags, questionnaire_permissions: :person)
    questionnaire_scope = questionnaire_scope.where(conditions.join(" and "), condition_vars) if conditions.any?
    @questionnaires = questionnaire_scope.paginate(page: params[:page] || 1, per_page: per_page)
    
    @rss_url = questionnaires_url(:format => "rss")

    respond_to do |format|
      format.html { }
      format.rss  { render :layout => false }
    end
  end
  
  def responses
    unless person_signed_in?
      return redirect_to(:action => 'index')
    end
    
    @responses = Response.where(:person_id => current_person.id). 
                              includes(:questionnaire => [:questionnaire_permissions, :tags]).
                              order("created_at DESC")
    @questionnaires = @responses.collect { |r| r.questionnaire }.uniq
  end

  # GET /questionnaires/1
  # GET /questionnaires/1.xml
  def show
    @questionnaire = Questionnaire.find(params[:id])
    authorize! :view_edit_pages, @questionnaire
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
    @questionnaire = Questionnaire.includes(:pages).find(params[:id])
    @resp = Response.new(:questionnaire => @questionnaire)
    authorize! :view_edit_pages, @questionnaire
    
    render :layout => "print"
  end

  # GET /questionnaires/new
  def new
    @questionnaire = Questionnaire.new(params[:questionnaire])
    @cloneable_questionnaires = Questionnaire.accessible_by(current_ability, :edit).order("questionnaires.id DESC").to_a.uniq
  end

  # GET /questionnaires/1;edit
  def edit
    authorize! :edit, @questionnaire
    render layout: "questionnaire_edit"
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
      @questionnaire = Questionnaire.find(params[:clone_questionnaire_id]).deepclone(params[:clone_responses] == "true")
      @questionnaire.title = "Copy of #{@questionnaire.title}"
      @questionnaire.is_open = false
    else
      @questionnaire = Questionnaire.new(create_params)
      @questionnaire.title ||= "Untitled questionnaire"
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
    authorize! :edit, @questionnaire

    respond_to do |format|
      if @questionnaire.update_attributes(update_params)
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
    authorize! :destroy, @questionnaire
    @questionnaire.destroy

    respond_to do |format|
      format.html { redirect_to questionnaires_url }
      format.xml  { head :ok }
    end
  end
  
  def available_special_field_purposes
    @questionnaire = Questionnaire.find(params[:id])
    authorize! :edit, @questionnaire
    
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
    authorize! :view_edit_pages, @questionnaire
    render :partial => 'pagelist', :locals => { :questionnaire => @questionnaire }
  end
  
  private
  def create_params
    params.require(:questionnaire).permit(permitted_params_for_edit_permission)
  end
  
  def update_params
    permitted_params = []
    permitted_params += permitted_params_for_edit_permission if can?(:edit, @questionnaire)
    if can?(:change_permissions, @questionnaire)
      permitted_params << { 
        questionnaire_permissions_attributes: [:email, :person_id, :can_edit, :can_view_answers, :can_edit_answers, :can_destroy, :can_change_permissions, :id, :_destroy] 
      }
    end
    params.require(:questionnaire).permit(permitted_params)
  end
  
  def permitted_params_for_edit_permission
    [:title, :is_open, :custom_html, :custom_css, :allow_finish_later, :allow_amend_response, 
      :welcome_text, :advertise_login, :require_login, :publicly_visible, :allow_preview, :allow_delete_responses]
  end
end
