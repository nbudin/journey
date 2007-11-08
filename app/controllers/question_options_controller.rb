class QuestionOptionsController < ApplicationController
  rest_edit_permissions :class_name => "Questionnaire", :id_param => "questionnaire_id"

  layout "answer"
  before_filter :get_question_questionnaire_and_page
  
  # GET /question_options
  # GET /question_options.xml
  def index
    @question_options = QuestionOption.find_all_by_question_id(@question.id)

    respond_to do |format|
      format.json { render :json => @question_options.to_json }
      format.xml  { render :xml => @question_options.to_xml }
    end
  end

  # GET /question_options/1
  # GET /question_options/1.xml
  def show
    @question_option = QuestionOption.find(params[:id])

    respond_to do |format|
      format.json { render :json => @question_option.to_json }
      format.xml  { render :xml => @question_option.to_xml }
    end
  end

  # GET /question_options/new
  def new
    @question_option = QuestionOption.new
  end

  # GET /question_options/1;edit
  def edit
    @question_option = QuestionOption.find(params[:id])
  end

  # POST /question_options
  # POST /question_options.xml
  def create
    @question_option = QuestionOption.new(params[:question_option])

    respond_to do |format|
      if @question_option.save
        format.json { head :created, :location => question_option_url(@questionnaire, @page, @question, @question_option) }
        format.xml  { head :created, :location => question_option_url(@questionnaire, @page, @question, @question_option) }
      else
        format.json { render :json => @question_option.errors.to_json }
        format.xml  { render :xml => @question_option.errors.to_xml }
      end
    end
  end

  # PUT /question_options/1
  # PUT /question_options/1.xml
  def update
    @question_option = QuestionOption.find(params[:id])

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

  # DELETE /question_options/1
  # DELETE /question_options/1.xml
  def destroy
    @question_option = QuestionOption.find(params[:id])
    @question_option.destroy

    respond_to do |format|
      format.json { head :ok }
      format.xml  { head :ok }
    end
  end
  
  def get_question_questionnaire_and_page
    @question = Question.find(params[:question_id])
    @questionnaire = Questionnaire.find(params[:questionnaire_id])
    @page = Page.find(params[:page_id])
  end
end
