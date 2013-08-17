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
                  elsif [:id, :submitted_at, :notes].include?(colspec.to_sym)
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
        
        stream_csv(@questionnaire.title + ".csv") do |csv|
          db = RailsSequel.connect
          
          ds = db[:answers]
          ds = ds.inner_join(:responses, :id => :response_id)
          ds = ds.inner_join(:questions, :id => :answers__question_id)
          ds = ds.inner_join(:pages, :id => :questions__page_id)
          ds = ds.left_join(:question_options, :question_id => :answers__question_id, :option => :answers__value)
          ds = ds.where(:responses__questionnaire_id => @questionnaire.id)

          case params[:rotate]
          when 'true'
            valid_response_ids = db[:answers].select(:response_id).inner_join(:responses, :id => :response_id).where(:questionnaire_id => @questionnaire.id)
            
            response_metadata = db[:responses].order(:id).where(:id => valid_response_ids).select(:id, :submitted_at, :notes).all
            response_ids = response_metadata.map { |resp| resp[:id] }
            csv << ["id"] + response_ids
            csv << ["Submitted"] + response_metadata.map { |resp| resp[:submitted_at] }
            csv << ["Notes"] + response_metadata.map { |resp| resp[:notes] }
            
            ds = ds.order(:pages__position, :questions__position, :responses__id)
            ds = ds.select(:answers__question_id, :questions__caption, :answers__response_id, :answers__value, :question_options__output_value)
            
            current_response_index = 0
            current_question_id = 0
            current_row = nil
            ds.each do |db_row|
              if db_row[:question_id] != current_question_id
                csv << current_row if current_row
                current_row = [db_row[:caption]]
                current_response_index = 0
                current_question_id = db_row[:question_id]
              end
              
              current_response_id = response_ids[current_response_index]
              if current_response_id != db_row[:response_id]
                skip_to = response_ids.find_index(db_row[:response_id])
                if skip_to
                  (skip_to - current_response_index).times { current_row << "" }
                  current_response_index = skip_to
                else
                  next
                end
              end
              
              db_row[:output_value] = nil if db_row[:output_value].blank?
              current_row << (db_row[:output_value] || db_row[:value] || "")
              current_response_index += 1
            end
            csv << current_row if current_row
          else
            @columns = @questionnaire.fields

            header = ["id", "Submitted", "Notes"]
            header += @columns.collect { |c| c.caption }
            csv << header
            
            ds = ds.order(Sequel.desc(:responses__id), :pages__position, :questions__position)
            ds = ds.select(:responses__id, :responses__submitted_at, :responses__notes, :answers__question_id, :answers__value, :question_options__output_value)
            
            column_ids = @columns.map(&:id)
            current_column_index = 0
            current_response_id = 0
            current_row = nil
            ds.each do |db_row|
              if db_row[:id] != current_response_id
                csv << current_row if current_row                
                current_row = [db_row[:id], db_row[:submitted_at], db_row[:notes]]
                current_column_index = 0
                current_response_id = db_row[:id]
              end
              
              current_column_id = column_ids[current_column_index]
              if current_column_id != db_row[:question_id]
                skip_to = column_ids.find_index(db_row[:question_id])
                if skip_to
                  (skip_to - current_column_index).times { current_row << "" }
                  current_column_index = skip_to
                else
                  next
                end
              end
              
              db_row[:output_value] = nil if db_row[:output_value].blank?
              current_row << (db_row[:output_value] || db_row[:value] || "")
              current_column_index += 1
            end
            csv << current_row if current_row
          end
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
    @response = Response.new(params[:response])

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
      if @response.update_attributes(params[:response])
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
end
