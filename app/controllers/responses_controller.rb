require 'csv'

class ResponsesController < ApplicationController
  load_resource :questionnaire
  load_and_authorize_resource :through => :questionnaire
  
  before_filter :set_page_title
  before_filter :require_view_answers_except_rss, :only => [:index]
  before_filter :get_email_notification, :only => [:subscribe, :update_subscription]
  
  # GET /responses
  # GET /responses.xml
  def index
    sort = params[:sort_column] || 'id'
    if params[:reverse] == "true"
      sort = "#{sort} DESC"
    end
        
    @rss_url = response_rss_url(@questionnaire)
    
    @responses = @questionnaire.valid_responses.paginate :page => params[:page]
    
    default_columns = ["title", "submitted_at", "notes"]
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
                  elsif %w(id submitted_at notes).include?(colspec.to_s)
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
      format.rss do 
        if params[:secret] != @questionnaire.rss_secret
          throw "Provided secret does not match questionnaire"
        end
        render :layout => false
      end
      format.csv do
        exporter = ResponsesCsvExporter.new(@questionnaire, params[:rotate] == 'true')
        stream_csv(@questionnaire.title.gsub(/[^A-Za-z0-9 \-\(\)\.]/, '-') + ".csv") do |csv|
          exporter.each_row { |row| csv << row }
        end
      end
    end
  end
  
  def print
    @responses = @questionnaire.valid_responses
    
    respond_to do |format|
      format.html { render :layout => "print" }
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
          page << "$$('#responsebody > form input[type=submit]').each(function(elt) { elt.hide(); });"
        end
      end
    end
  end

  # GET /responses/1/edit
  def edit
    @editing = true
    
    respond_to do |format|
      format.html
      format.js do
        content = render_to_string(:layout => false)
        render :update do |page|
          page.replace_html 'responsebody', content
          page.replace_html 'responsetitle', "Editing #{@response.title}"
          page.call 'showResponseEditor', @response.id
        end
      end
    end
  end

  # POST /responses
  # POST /responses.xml
  def create
    @response = Response.new(response_params)

    respond_to do |format|
      if @response.save
        flash[:notice] = 'Response was successfully created.'
        format.html { redirect_to(url_for([@questionnaire, @response])) }
        format.xml  { render :xml => @response, :status => :created, :location => @response }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @response.errors, :status => :unprocessable_entity }
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
    
    @questionnaire.questions.each do |question|
      if question.kind_of? Questions::Field
        ans = Answer.find_answer(@response, question)
        if answer_given(question.id)
          if ans.nil?
            ans = Answer.new :question_id => question.id, :response_id => @response.id
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
      if @response.update_attributes(response_params)
        format.html { redirect_to([@questionnaire, @response]) }
        format.js { redirect_to(polymorphic_url([@questionnaire, @response], :format => "js")) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.js { render :action => "edit" }
        format.xml  { render :xml => @response.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /responses/1
  # DELETE /responses/1.xml
  def destroy
    @response.destroy

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
  
  def subscribe
  end
  
  def update_subscription
    unless @email_notification
      @email_notification = @questionnaire.email_notifications.new.tap { |n| n.person = current_person }
      @email_notification.save!
    end
    
    if @email_notification.update_attributes(params[:email_notification])
      respond_to do |format|
        format.html { redirect_to action: 'subscribe' }
      end
    else
      respond_to do |format|
        format.html { render action: "subscribe" }
      end
    end
  end
  
  private
  def stream_csv(filename)
    content_type = 'text/csv'
    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      content_type = 'text/plain'
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Expires'] = "0"
    end

    # Generate a valid tempfile name
    tmpfile = Tempfile.new(filename)
    pathname = tmpfile.path
    tmpfile.close
    
    output_path = pathname + '-nontemp'
    CSV.open(output_path, "w", :row_sep => "\r\n") do |csv|
      yield csv
    end
    send_file(output_path, :type => content_type, :disposition => "attachment", :filename => filename)
  end
  
  def set_page_title
    @page_title = "Responses"
  end
  
  def require_view_answers_except_rss
    unless params[:format].to_s == 'rss'
      authorize! :show, Response.new(:questionnaire => @questionnaire)
    end
  end
  
  def get_email_notification
    @email_notification = @questionnaire.email_notifications.where(person_id: current_person.id).first
  end
  
  def response_params
    params[:response].try(:permit, :notes) || {}
  end
end
