class QuestionOptionsController < ApplicationController
  load_resource :questionnaire
  load_resource :page, :through => :questionnaire
  load_resource :question, :through => :page
  load_and_authorize_resource :through => :question

  layout "answer"
  
  # GET /question_options
  # GET /question_options.xml
  def index
    respond_to do |format|
      format.json { render :json => @question_options.to_json }
      format.xml  { render :xml => @question_options.to_xml }
    end
  end

  # GET /question_options/1
  # GET /question_options/1.xml
  def show
    respond_to do |format|
      format.json { render :json => @question_option.to_json }
      format.xml  { render :xml => @question_option.to_xml }
    end
  end

  # POST /question_options
  # POST /question_options.xml
  def create
    respond_to do |format|
      if @question_option.save
        format.json { head :created, :location => polymorphic_url([@questionnaire, @page, @question.becomes(Question), @question_option], :format => 'json') }
        format.xml  { head :created, :location => polymorphic_url([@questionnaire, @page, @question.becomes(Question), @question_option], :format => 'xml') }
      else
        format.json { render :json => @question_option.errors.to_json }
        format.xml  { render :xml => @question_option.errors.to_xml }
      end
    end
  end

  # PUT /question_options/1
  # PUT /question_options/1.xml
  def update
    respond_to do |format|
      if @question_option.update_attributes(params[:question_option])
        format.json { head :ok }
        format.xml  { head :ok }
      else
        format.json { render :json => @question_option.errors.to_json }
        format.xml  { render :xml => @question_option.errors.to_xml }
      end
    end
  end
  
  def sort
    @question_options = @question.question_options
    @question_options.each do |option|
      option.position = params['options'].index(option.id.to_s) + 1
      option.save!
    end
    render :nothing => true
  end

  # DELETE /question_options/1
  # DELETE /question_options/1.xml
  def destroy
    @question_option.destroy

    respond_to do |format|
      format.json { head :ok }
      format.xml  { head :ok }
    end
  end
end
