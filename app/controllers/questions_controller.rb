class QuestionsController < ApplicationController
  ALLOWED_QUESTION_TYPES = %w(
    Questions::BigTextField
    Questions::CheckBoxField
    Questions::Divider
    Questions::DropDownField
    Questions::Heading
    Questions::Label
    Questions::RadioField
    Questions::RangeField
    Questions::TextField
  ).map { |typ| [typ, typ.constantize] }.to_h
  
  load_resource :questionnaire
  load_resource :page, :through => :questionnaire
  load_and_authorize_resource :through => :page, :except => [:create]
  
  layout "answer", :except => [:edit]

  # GET /questions
  # GET /questions.xml
  def index
    respond_to do |format|
      format.json { render :text => @questions.to_json }
      format.xml  { render :xml => @questions.to_xml }
    end
  end

  # GET /questions/1
  # GET /questions/1.xml
  def show
    respond_to do |format|
      format.json { render :json => @question.to_json }
      format.xml  { render :xml => @question.to_xml(:methods => [:purpose]) }
    end
  end

  # GET /questions/1;edit
  def edit
    render layout: false
  end
  
  # GET /questions/1;edit_options
  def edit_options
    @suppress_custom_html = true
    @suppress_custom_css = true
  end

  # POST /questions
  # POST /questions.xml
  def create
    question_class = ALLOWED_QUESTION_TYPES[params[:question][:type]]
    raise "#{params[:question][:type]} is not a valid question type" unless question_class
    
    params[:question][:caption] ||= if question_class <= Questions::Field
      "Click here to type a question."
    else
      ""
    end
    
    @question = question_class.new(question_params.except(:type))    
    @question.page = @page
    authorize! :create, @question

    respond_to do |format|
      if @question.save
        format.xml  { head(:created, :location => polymorphic_url([@questionnaire, @page, @question.becomes(Question)], :format => 'xml')) }
        format.json { head(:created, :location => polymorphic_url([@questionnaire, @page, @question.becomes(Question)], :format => 'json')) }
      else
        format.xml  { render :xml => @question.errors.to_xml, :status => 500 }
        format.json { render :json => @question.errors.to_json, :status => 500 }
      end
    end
  end

  # PUT /questions/1
  # PUT /questions/1.xml
  def update
    respond_to do |format|
      if @question.update_attributes(question_params)
        if params[:question].has_key?(:purpose)
          @question.purpose = params[:question][:purpose]
        end
        format.html { redirect_to [@questionnaire, @page, @question] }
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
    @question.destroy

    respond_to do |format|
      format.html { redirect_to [@questionnaire, @page] }
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
    times = params[:times] || 1
    
    i = @page.questions.index(@question) + 1
    times.to_i.times do
      c = @question.deepclone
      c.purpose = nil
      @page.questions.insert(i, c)
      c.save!
    end
    
    render :nothing => true
  end

  private
  def question_params
    params.require(:question).permit(:type, :position, :caption, :required, :min, :max, :step, :default_answer, :layout, :radio_layout, :purpose)
  end
end
