class AnswerController < ApplicationController
  before_filter :check_required_login, :only => [:start]
  
  def resume
    @resp = Response.find(params[:id])
    if @resp.person != logged_in_person
      raise "That response does not belong to you.  Either log in as a different person, or start a new response."
    else
      # If this is an amended response, we want to retract the submitted response set.
      if @resp.submitted
        if not @resp.questionnaire.allow_amend_response
          raise "This questionnaire does not allow you to amend submitted responses."
        end
        @resp.submitted = false
        @resp.save
      else
        if not @resp.questionnaire.allow_finish_later
          raise "This questionnaire does not allow you to resume a session."
        end
      end

      qid = @resp.questionnaire.id
      session["response_#{qid}"] = @resp.id
      redirect_to :action => 'index', :id => qid, :page => @resp[:saved_page]
    end
  rescue
    @flash[:error_messages] = [$!.to_s]
    redirect_to :action => 'prompt', :id => @resp.questionnaire.id
  end
  
  def prompt
    @questionnaire = Questionnaire.find(params[:id])
    
    if logged_in?
      @responses = @questionnaire.responses.find_all_by_person_id(logged_in_person.id)
    end
  end
  
  def start
    @questionnaire = Questionnaire.find(params[:id])
    
    @resp = Response.new :questionnaire => @questionnaire
    if logged_in?
      @resp.person = logged_in_person
    end
    @resp.save!
    session["response_#{@questionnaire.id}"] = @resp.id
    
    redirect_to :action => 'index', :id => @questionnaire.id
  end

  def index
    @questionnaire = Questionnaire.find(params[:id], :include => :pages)
    if not @questionnaire.is_open
      redirect_to :action => 'questionnaire_closed', :id => params[:id]
    else
      response_key = "response_#{@questionnaire.id}"
      if not session[response_key]
        redirect_to :action => 'prompt', :id => @questionnaire.id
      else
        begin
          @resp = Response.find(session[response_key])
        rescue ActiveRecord::RecordNotFound
          # bad response ID, it may have been deleted by an admin
          session[response_key] = nil
          redirect_to :action => prompt, :id => params[:id]
        else
          if params[:page]
            @page = @resp.questionnaire.pages[params[:page].to_i - 1]
          else
            @page = @resp.questionnaire.pages[0]
          end

          if logged_in?
            @page.questions.each do |question|
              if not question.respond_to? 'purpose'
                next
              end
              purpose = question.purpose
              if purpose
                answer = @resp.answer_for_question(question)
                if not answer
                  value = nil
                  if purpose == 'name'
                    value = logged_in_person.name
                  elsif purpose == 'email'
                    value = logged_in_person.primary_email_address
                  elsif purpose == 'gender'
                    value = logged_in_person.gender
                  end
                  if not (value.nil? or value == '')
                    @resp.answers.create :question => question, :value => value
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def questionnaire_closed
    @questionnaire = Questionnaire.find(params[:id])
  end

  def validate_answers(resp, page)
    errors = []
    page.questions.each do |question|
      if question.kind_of? Field and question.required
        if not answer_given(question.id)
            errors << "You didn't answer the question \"#{question.caption}\", which is required."
        end
      end
    end
    return errors
  end

  def answer_given(question_id)
    return (params[:question] and not params[:question][question_id.to_s].blank? and
      params[:question][question_id.to_s].length > 0)
  end

  def save_session
    @resp = Response.find(session["response_#{params[:id]}"])
    if not @resp.questionnaire.allow_finish_later and not @resp.submitted
      @flash[:error_messages] = ["This questionnaire does not allow you to resume answering later."]
      redirect_to :action => "answer", :id => @resp.questionnaire.id, :page => params[:current_page]
    end

    if not (@resp.submitted and not @resp.questionnaire.allow_amend_response)
      @page = @resp.questionnaire.pages[params[:current_page].to_i - 1]
      @resp.saved_page = params[:current_page]
      @resp.save
    end

    session["response_#{params[:id]}"] = nil
  end

  def save_answers
    @resp = Response.find(session["response_#{params[:id]}"])
    @page = @resp.questionnaire.pages[params[:current_page].to_i - 1]

    @page.questions.each do |question|
      if question.kind_of? Field
        ans = @resp.answer_for_question(question)
        if answer_given(question.id)
          if ans.nil?
            ans = Answer.new :question_id => question.id, :response_id => @resp.id
          end
          ans.value = params[:question][question.id.to_s]
          ans.save
        else
          # No answer provided
          if not ans.nil?
            ans.destroy
          end
        end
      end
    end

    if params[:commit] =~ /later/i
      redirect_to :action => "save_session", :id => @resp.questionnaire.id, :current_page => params[:current_page]
      return
    else
      offset = if params[:commit] =~ /[<>]/
        params[:commit] =~ />/ ? 1 : -1
      else
        0
      end
      if offset != -1
        errors = validate_answers(@resp, @page)
        if errors.length > 0
          flash[:error_messages] = errors
          redirect_to :action => "index", :id => @resp.questionnaire.id, :page => params[:current_page]
          return
        end
      end
      if offset == 0
        @resp.submitted = true
        @resp.save
        redirect_to :action => "save_session", :id => @resp.questionnaire.id, :current_page => 1
      else
        new_page = params[:current_page].to_i + offset
        @resp.saved_page = new_page
        @resp.save
        redirect_to :action => "index", :id => @resp.questionnaire.id, :page => new_page
      end
    end
  end
  
  private
  def check_required_login
    @questionnaire = Questionnaire.find params[:id]
    if @questionnaire.require_login and not logged_in?
      redirect_to :action => "prompt", :id => params[:id]
    end
  end
end
