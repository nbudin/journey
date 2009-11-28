begin
  require 'fastercsv'
rescue
  require 'csv'
  FasterCSV = CSV
end
require 'iconv'

class ResponsesController < ApplicationController
  perm_options = {:class_name => "Questionnaire", :id_param => "questionnaire_id"}
  require_permission "view_answers", { :except => [:index] }.update(perm_options)
  require_permission "edit_answers", {:only => [:new, :edit, :create, :update, :sort]}.update(perm_options)
  
  before_filter :get_questionnaire
  before_filter :set_page_title
  before_filter :require_view_answers_except_rss, :only => [:index]
  before_filter :require_edit_answers_or_own_response, :only => [:destroy]
    
  # GET /responses
  # GET /responses.xml
  def index
    sort = params[:sort_column] || 'id'
    if params[:reverse] == "true"
      sort = "#{sort} DESC"
    end
        
    @rss_url = responses_url(@questionnaire, :format => "rss", :secret => @questionnaire.rss_secret)
    
    @responses = @questionnaire.valid_responses.paginate :page => params[:page]
    
    default_columns = ["title", "submitted_at"]
    default_columns += @questionnaire.special_field_associations.select { |sfa| sfa.purpose != 'name' }.collect { |sfa| sfa.question }
    default_columns.push("id")
    
    @columns = []
    1.upto(5) do |i|
      colspec = params["column_#{i}".to_sym]
      thiscol = if colspec
                  if md = /^question_(\d+)$/.match(colspec)
                    q = Question.find(md[1])
                    if q and q.questionnaire == @questionnaire
                      q
                    end
                  elsif [:id, :submitted_at].include?(colspec.to_sym)
                    colspec
                  end
                end
      if thiscol.nil?
        thiscol = default_columns.shift
      end
      @columns.push(thiscol) if thiscol
    end

    respond_to do |format|
      format.html { }
      format.js do
        render :update do |page|
          page.replace_html 'responses', :partial => 'response_table'
        end
      end
      format.rss do 
        if params[:secret] != @questionnaire.rss_secret
          throw "Provided secret does not match questionnaire"
        end
        render :layout => false
      end
      format.csv do
        @responses = @questionnaire.valid_responses
        @columns = @questionnaire.fields
        
        stream_csv(@questionnaire.title + ".csv") do |csv|
          if params[:rotate] == 'true'
            csv << (["id"] + @responses.collect { |r| r.id })
            @columns.each do |col|
              csv << ([col.caption] + @responses.collect do |r|
                a = r.answer_for_question(col)
                if a
                  a.output_value
                else
                  ""
                end
              end)
            end
          else
            csv << (["id"] + @columns.collect { |c| c.caption })
            @responses.each do |resp|
              csv << ([resp.id] + @columns.collect do |c|
                a = resp.answer_for_question(c)
                if a
                  a.output_value
                else
                  ""
                end
              end)
            end
          end
        end
      end
    end
  end
  
  def print
    respond_to do |format|
      format.html { render :layout => "print" }
    end
  end
  
  def responseviewer
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  # GET /responses/1
  # GET /responses/1.xml
  def show
    @resp = Response.find(params[:id])

    respond_to do |format|
      format.html
      format.js do
        content = render_to_string(:layout => false)
        render :update do |page|
          page.replace_html 'responsebody', content
          page.replace_html 'responsetitle', @resp.title
          page.call 'showResponseViewer', @resp.id
        end
      end
    end
  end

  # GET /responses/new
  # GET /responses/new.xml
  def new
    @resp = Response.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @resp }
    end
  end

  # GET /responses/1/edit
  def edit
    @resp = Response.find(params[:id])
    @editing = true
    
    respond_to do |format|
      format.html
      format.js do
        content = render_to_string(:layout => false)
        render :update do |page|
          page.replace_html 'responsebody', content
          page.replace_html 'responsetitle', "Editing #{@resp.title}"
          page.call 'showResponseEditor', @resp.id
        end
      end
    end
  end

  # POST /responses
  # POST /responses.xml
  def create
    @response = Response.new(params[:response])

    respond_to do |format|
      if @resp.save
        flash[:notice] = 'Response was successfully created.'
        format.html { redirect_to(response_url(@questionnaire, @resp)) }
        format.xml  { render :xml => @resp, :status => :created, :location => @resp }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @resp.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /responses/1
  # PUT /responses/1.xml
  def update
    def answer_given(question_id)
      return (params[:answer] and params[:answer][question_id.to_s] and
         params[:answer][question_id.to_s].length > 0)
    end
    
    @resp = Response.find(params[:id])

    @questionnaire.questions.each do |question|
      if question.kind_of? Questions::Field
        ans = Answer.find_answer(@resp, question)
        if answer_given(question.id)
          if ans.nil?
            ans = Answer.new :question_id => question.id, :response_id => @resp.id
          end
          ans.value = params[:answer][question.id.to_s]
          ans.save
        else
          # No answer provided
          if not ans.nil?
            ans.destroy
          end
        end
      end
    end

    respond_to do |format|
      if @resp.update_attributes(params[:response])
        format.html { redirect_to(response_url(@questionnaire, @resp)) }
        format.js { redirect_to(response_url(@questionnaire, @resp, :format => "js")) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.js { render :action => "edit" }
        format.xml  { render :xml => @resp.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /responses/1
  # DELETE /responses/1.xml
  def destroy
    @resp.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.xml  { head :ok }
    end
  end
  
  def aggregate  
    @page_title = "Response graphs"
    @fields = @questionnaire.fields.select { |f| not f.kind_of? Questions::FreeformField }
    @numeric_fields = @fields.select { |f| f.is_numeric? }
    @nonnumeric_fields = @fields.select { |f| not f.is_numeric? }
  end
  
  def export
    
  end
  
  private
  def stream_csv(filename)
    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers['Content-type'] = 'text/plain'
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Expires'] = "0"
    else
      headers['Content-Type'] ||= 'text/csv'
    end
    headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
    
    output = StringIO.new
    csv = FasterCSV.new(output, :row_sep => "\r\n")
    yield csv
    begin
      c = Iconv.new('ISO-8859-15', 'UTF-8')
      render :text => c.iconv(output.string)
    rescue Iconv::IllegalSequence
      # this won't work in excel but might work other places
      render :text => output.string
    end
  end
  
  def set_page_title
    @page_title = "Responses"
  end
  
  def get_questionnaire
    @questionnaire = Questionnaire.find(params[:questionnaire_id], :include => [:valid_responses, :pages])
  end
  
  def require_view_answers_except_rss
    unless params[:format].to_s == 'rss'
      do_permission_check(@questionnaire, "view_answers", "Sorry, but you are not permitted to view answers to this survey.")
    end
  end
  
  def require_edit_answers_or_own_response
    @resp = Response.find(params[:id])
    unless @questionnaire.allow_delete_responses and logged_in? and logged_in_person == @resp.person
      do_permission_check(@questionnaire, "edit_answers", "Sorry, but you are not permitted to edit answers to this survey.")
    end
  end
end
