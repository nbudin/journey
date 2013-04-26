class QuestionsController < ApplicationController
  load_resource :questionnaire
  load_resource :page, :through => :questionnaire
  load_and_authorize_resource :through => :page

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
    check_forged_path

    respond_to do |format|
      format.html # show.rhtml
      format.json { render :json => @question.to_json }
      format.xml  { render :xml => @question.to_xml(:methods => [:purpose]) }
    end
  end

  # GET /questions/new
  def new
    @question = Question.new
  end

  # GET /questions/1;edit
  def edit
    @question = Question.find(params[:id])
    check_forged_path
  end
  
  # GET /questions/1;edit_options
  def edit_options
    @question = Question.find(params[:id])
    check_forged_path
    @suppress_custom_html = true
    @suppress_custom_css = true
  end

  # POST /questions
  # POST /questions.xml
  def create
    @question.caption ||= ""
    @question.page = @page

    respond_to do |format|
      if @question.save and @question.update_attribute(:type, params[:question][:type])
        @question = Question.find(@question.id)
        if @question.kind_of? Questions::Field and @question.caption.blank?
          # get the default field caption in
          @question.caption = "Click here to type a question."
          @question.save
        end
        
        format.html { redirect_to question_url(@question) }
        format.xml  { head(:created, :location => question_url(@questionnaire, @page, @question, :format => 'xml')) }
        format.json { head(:created, :location => question_url(@questionnaire, @page, @question, :format => 'json')) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @question.errors.to_xml, :status => 500 }
        format.json { render :json => @question.errors.to_json, :status => 500 }
      end
    end
  end

  # PUT /questions/1
  # PUT /questions/1.xml
  def update
    @question = Question.find(params[:id])
    check_forged_path

    respond_to do |format|
      if @question.update_attributes(params[:question])
        if params[:question].has_key?(:purpose)
          @question.purpose = params[:question][:purpose]
        end
        format.html { redirect_to question_url(@question) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @question.errors.full_messages.to_xml, :status => :bad_request }
        format.json { render :json => @question.errors.full_messages.join("\n").to_json, :status => :bad_request }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.xml
  def destroy
    @question = Question.find(params[:id])
    check_forged_path
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
      question.save!
    end
    render :nothing => true
  end
  
  def duplicate
    @question = Question.find(params[:id])
    @times = params[:times] || 1
    check_forged_path
    
    i = @page.questions.index(@question) + 1
    @times.to_i.times do
      c = @question.deepclone
      @page.questions.insert(i, c)
      c.save
    end
    
    render :nothing => true
  end

  private
  def check_forged_path
    if @question.page != @page
      access_denied "That question ID does not match the page given."
    end
  end
  
  def get_questionnaire_and_page
    @questionnaire = Questionnaire.find(params[:questionnaire_id])
    @page = Page.find(params[:page_id])
    if @page.questionnaire != @questionnaire
      access_denied "That page ID does not match the questionnaire given."
    end
  end
end
