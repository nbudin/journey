class AnswerController < ApplicationController
  def resume
    if params[:session_code]
      session_id = params[:session_code].split('-')[0].to_i
      @resp = Response.find(session_id)
      if @resp.session_code != params[:session_code]
        raise "The session code you entered could not be retrieved.  Please try again."
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
    end
  rescue
    @flash[:errors] = [$!.to_s]
  end

  def index
    @questionnaire = Questionnaire.find(params[:id])
    if not @questionnaire.is_open
      redirect_to :action => 'questionnaire_closed', :id => params[:id]
    else
      response_key = "response_#{@questionnaire.id}"
      if session[response_key]
        @resp = Response.find(session[response_key])
      else
        @resp = Response.create :questionnaire => @questionnaire
        session[response_key] = @resp.id
      end
      if params[:page]
        @page = @resp.questionnaire.pages[params[:page].to_i - 1]
      else
        @page = @resp.questionnaire.pages[0]
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
    return (params[:question] and params[:question][question_id.to_s] and
      params[:question][question_id.to_s].length > 0)
  end

  def save_session
    @resp = Response.find(session["response_#{params[:id]}"])
    if not @resp.questionnaire.allow_finish_later and not @resp.submitted
      @flash[:errors] = ["This questionnaire does not allow you to resume answering later."]
      redirect_to :action => "answer", :id => @resp.questionnaire.id, :page => params[:current_page]
    end

    if not (@resp.submitted and not @resp.questionnaire.allow_amend_response)
      @page = @resp.questionnaire.pages[params[:current_page].to_i - 1]
      @resp.saved_page = params[:current_page]
      @resp.session_code = SHA1.sha1("#{@resp.questionnaire.id}_#{@page.id}_#{Time.now.to_s}").to_s[0..5]
      @resp.session_code = "#{@resp.id}-#{@resp.session_code}"
      @resp.save
    end

    session["response_#{params[:id]}"] = nil
  end

  def save_answers
    @resp = Response.find(session["response_#{params[:id]}"])
    @page = @resp.questionnaire.pages[params[:current_page].to_i - 1]

    @page.questions.each do |question|
      if question.kind_of? Field
        ans = Answer.find_answer(@resp, question)
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
          flash[:errors] = errors
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
end
