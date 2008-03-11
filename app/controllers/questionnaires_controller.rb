require 'paginator'

class QuestionnairesController < ApplicationController
  rest_edit_permissions

  # GET /questionnaires
  # GET /questionnaires.xml
  def index
    p = logged_in? ? logged_in_person : nil
    all_questionnaires = Questionnaire.find(:all, :order => 'id DESC')
    permitted_questionnaires = all_questionnaires.select do |q|
      q.is_open or (p and Questionnaire.permission_names.any? { |pn| p.permitted?(q, pn) })
    end
    pager = ::Paginator.new(permitted_questionnaires.size, 5) do |offset, per_page|
      permitted_questionnaires[offset, per_page]
    end
    @questionnaires = returning WillPaginate::Collection.new(params[:page] || 1, 5, permitted_questionnaires.size) do |p|
      p.replace pager.page(params[:page]).items
    end

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @questionnaires.to_xml }
    end
  end

  # GET /questionnaires/1
  # GET /questionnaires/1.xml
  def show
    @questionnaire = Questionnaire.find(params[:id])

    respond_to do |format|
      format.xml do
        if logged_in? and logged_in_person.permitted?(@questionnaire, "edit")
          render :xml => @questionnaire.to_xml
        else
          response.headers["Content-type"] = "text/html"
          access_denied("Sorry, but you are not allowed to edit this questionnaire.")
        end
      end
    end
  end

  # GET /questionnaires/new
  def new
    @questionnaire = Questionnaire.new
  end

  # GET /questionnaires/1;edit
  def edit
    @questionnaire = Questionnaire.find(params[:id])
  end

  # POST /questionnaires
  # POST /questionnaires.xml
  require_login :only => [:create]
  def create
    if params[:file]
      begin
        @questionnaire = Questionnaire.from_xml(params[:file].read)
      rescue Exception => ex
        flash[:errors] = ["There was an error parsing the JQML file you uploaded.  Please check to make sure it is a valid JQML file."]
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
        format.html { redirect_to edit_questionnaire_url(@questionnaire) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @questionnaire.errors.to_xml }
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
