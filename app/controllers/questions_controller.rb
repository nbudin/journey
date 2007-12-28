class QuestionsController < ApplicationController
  perm_options = {:class_name => "Questionnaire", :id_param => "questionnaire_id"}
  require_permission "edit", {:only => [:destroy, :new, :edit, :create, :update, :sort]}.update(perm_options)

  layout "answer"
  layout nil, :only => [:edit]
  before_filter :get_questionnaire_and_page

  # GET /questions
  # GET /questions.xml
  def index
    @questions = Question.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.json { render :text => @questions.to_json }
      format.xml  { render :xml => @questions.to_xml }
    end
  end

  # GET /questions/1
  # GET /questions/1.xml
  def show
    @question = Question.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.json { render :json => @question.to_json }
      format.xml  { render :xml => @question.to_xml }
    end
  end

  # GET /questions/new
  def new
    @question = Question.new
  end

  # GET /questions/1;edit
  def edit
    @question = Question.find(params[:id])
  end

  # POST /questions
  # POST /questions.xml
  def create
    @question = Question.new(params[:question])
    @question.page = @page

    respond_to do |format|
      if @question.save and @question.update_attribute(:type, params[:question][:type])
        @question = Question.find(@question.id)
        format.html { redirect_to question_url(@question) }
        format.xml  { head :created, :location => questionnaire_page_question_url(@questionnaire, @page, @question) }
        format.json { head :created, :location => questionnaire_page_question_url(@questionnaire, @page, @question) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @question.errors.to_xml }
      end
    end
  end

  # PUT /questions/1
  # PUT /questions/1.xml
  def update
    @question = Question.find(params[:id])

    respond_to do |format|
      if @question.update_attributes(params[:question])
        format.html { redirect_to question_url(@question) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @question.errors.to_xml }
        format.json { render :json => @question.errors.to_json }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.xml
  def destroy
    @question = Question.find(params[:id])
    @question.destroy

    respond_to do |format|
      format.html { redirect_to questions_url(@questionnaire, @page) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
  
  def sort
    @questions = @page.questions
    @questions.each do |question|
      question.position = params['questions'].index(question.id.to_s) + 1
      question.save
    end
    render :nothing => true
  end

  def get_questionnaire_and_page
    @questionnaire = Questionnaire.find(params[:questionnaire_id])
    @page = Page.find(params[:page_id])
  end
end
