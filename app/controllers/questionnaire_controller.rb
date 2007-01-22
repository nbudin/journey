require "sha1"

class QuestionnaireController < ApplicationController
  layout :choose_layout
  
  def choose_layout
    if ['resume', 'answer', 'validate_answers', 'save_session', 'save_answers', 'questionnaire_closed'].include? @params[:action]
      'questionnaire'
    else
      'global'
    end
  end
  
  def new
    @editing = false
  end
  
  def index
  end
  
  def create_questionnaire
    @questionnaire = Questionnaire.create(@params[:questionnaire])
    redirect_to :action => 'index'
  end
  
  def delete
    @questionnaire = Questionnaire.find(@params[:id])
    if @params[:confirm]
      qname = @questionnaire.title
      @questionnaire.destroy
      @flash[:notice] = "Questionnaire \"#{qname}\" deleted."
      redirect_to :action => 'index'
    end
  end
  
  def edit
    @questionnaire = Questionnaire.find(@params[:id])
  end
  
  def resume
    if @params[:session_code]
      session_id = @params[:session_code].split('-')[0].to_i
      @resp = Response.find(session_id)
      if @resp.session_code != @params[:session_code]
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
        @session["response_#{qid}"] = @resp
        redirect_to :action => 'answer', :id => qid, :page => @resp[:saved_page]
      end
    end
  rescue
    @flash[:errors] = [$!.to_s]
  end
  
  def answer
    @questionnaire = Questionnaire.find(@params[:id])
    if not @questionnaire.is_open
      redirect_to :action => 'questionnaire_closed', :id => @params[:id]
    else
      response_key = "response_#{@questionnaire.id}"
      if @session[response_key]
        @resp = @session[response_key]
      else
        @resp = Response.create :questionnaire => @questionnaire
        @session[response_key] = @resp
      end
      if @params[:page]
        @page = @resp.questionnaire.pages[@params[:page].to_i - 1]
      else
        @page = @resp.questionnaire.pages[0]
      end
      @resp.verify_answers_for_page @page
    end
  end
  
  def questionnaire_closed
    @questionnaire = Questionnaire.find(@params[:id])
  end
  
  def validate_answers(resp, page)
    errors = []
    page.questions.each do |question|
      if question.kind_of? Field and question.required
        ans = Answer.find_answer(resp, question)
        if not (@params[:answer] and @params[:answer][ans.id.to_s] and @params[:answer][ans.id.to_s][:value] and @params[:answer][ans.id.to_s][:value].length > 0)
            errors << "You didn't answer the question \"#{question.caption}\", which is required."
        end
      end
    end
    return errors
  end
  
  def save_session
    @resp = @session["response_#{@params[:id]}"]
    if not @resp.questionnaire.allow_finish_later and not @resp.submitted
      @flash[:errors] = ["This questionnaire does not allow you to resume answering later."]
      redirect_to :action => "answer", :id => @resp.questionnaire.id, :page => @params[:current_page]
    end
    
    if not (@resp.submitted and not @resp.questionnaire.allow_amend_response)
      @page = @resp.questionnaire.pages[@params[:current_page].to_i - 1]
      @resp.saved_page = @params[:current_page]
      @resp.session_code = SHA1.sha1("#{@resp.questionnaire.id}_#{@page.id}_#{Time.now.to_s}").to_s[0..5]
      @resp.session_code = "#{@resp.id}-#{@resp.session_code}"
      @resp.save
    end
    
    @session["response_#{@params[:id]}"] = nil
  end
  
  def save_answers
    @resp = @session["response_#{@params[:id]}"]
    @page = @resp.questionnaire.pages[params[:current_page].to_i - 1]
    
    @page.questions.each do |question|
      if question.kind_of? Field
        ans = Answer.find_answer(@resp, question)
        if @params[:answer] and @params[:answer][ans.id.to_s]
          ans.value = @params[:answer][ans.id.to_s][:value]
          ans.save
        end
      end
    end
    
    if @params[:commit] =~ /later/i
      redirect_to :action => "save_session", :id => @resp.questionnaire.id, :current_page => @params[:current_page]
      return
    else
      offset = if @params[:commit] =~ /[<>]/
        @params[:commit] =~ />/ ? 1 : -1
      else
        0
      end
      if offset != -1
        errors = validate_answers(@resp, @page)
        if errors.length > 0
          flash[:errors] = errors
          redirect_to :action => "answer", :id => @resp.questionnaire.id, :page => @params[:current_page]
          return
        end
      end
      if offset == 0
        @resp.submitted = true
        @resp.save
        redirect_to :action => "save_session", :id => @resp.questionnaire.id, :current_page => 1
      else
        redirect_to :action => "answer", :id => @resp.questionnaire.id, :page => (@params[:current_page].to_i + offset)
      end
    end
  end
  
  def set_open
    @questionnaire = Questionnaire.find(@params[:id])
    @questionnaire.is_open = (@params[:status] == 'open')
    @questionnaire.save
    
    redirect_to :action => 'index'
  end
  
  def change_questionnaire_params
    @questionnaire = Questionnaire.find(@params[:id])
    @questionnaire.update_attributes(@params[:questionnaire][@params[:id]])
    @questionnaire.save
    
    redirect_to :action => 'edit', :id => @questionnaire.id
  end
  
  def add_page_to_questionnaire
    @questionnaire = Questionnaire.find(@params[:id])
    @page = Page.create :questionnaire_id => @questionnaire.id
    @page.insert_at(@params[:position])
    
    redirect_to :action => 'edit', :id => @questionnaire.id
  end
  
  def delete_page
    @questionnaire = Page.find(@params[:id]).questionnaire
    html = render :action => 'edit'
    
    Page.delete(@params[:id])
    return html
  end
  
  def change_page_title
    @page = Page.find(@params[:id])
    @page.title = @params[:page][@params[:id]][:title]
    @page.save
    
    @questionnaire = @page.questionnaire
    render :action => 'edit'
  end
  
  def add_question_to_page
    @page = Page.find(@params[:id])
    @question = Question.new
    @question.page_id = @page.id
    @question.type = 'Question'
    @question.save
    @question.insert_at(@params[:position])
    
    @questionnaire = @page.questionnaire
    render :partial => "editpage"
  end
  
  def delete_question
    @page = Question.find(@params[:id]).page
    @questionnaire = @page.questionnaire
    html = render :partial => "editpage"

    Question.delete(@params[:id])
    return html
  end
  
  def change_question_type
    @question = Question.find(@params[:id])
    @question.update_attribute(:type, @params[:type])
    @question.save
    
    @question = Question.find(@params[:id])
    @page = @question.page
    render :partial => "editquestion", :locals => { :question => @question }
  end
  
  def change_field_purpose
    @question = Question.find(@params[:id])
    if not @params[:purpose].empty?
      if @question.special_field_association.nil?
        @question.create_special_field_association :questionnaire => @question.questionnaire,
          :purpose => @params[:purpose]
      else
        sfa = @question.special_field_association
        sfa.purpose = @params[:purpose]
        sfa.save
      end
    else
      if not @question.special_field_association.nil?
        @question.special_field_association.destroy
      end
    end
    
    @question.reload
    @page = @question.page
    render :partial => "editquestion", :locals => { :question => @question }
  end
  
  def add_option_to_question
    option = QuestionOption.new :option => @params[:option]
    @question = Question.find(@params[:id])
    @question.question_options << option
    
    @page = @question.page
    render :partial => "editquestion", :locals => { :question => @question }
  end
  
  def remove_options_from_question
    QuestionOption.destroy(@params[:options])
    
    @question = Question.find(@params[:id])
    @page = @question.page
    render :partial => "editquestion", :locals => { :question => @question }
  end
  
  def change_default_answer
    id = @params[:id]
    @question = Question.find(id)
    @question.default_answer = @params[:question][id][:default_answer]
    @question.save
    
    @page = @question.page
    render :partial => "editquestion", :locals => { :question => @question }
  end
  
  def change_question_attrs
    id = @params[:id]
    @question = Question.find(id)
    if @params[:question][id].has_key? :caption
      @question.caption = @params[:question][id][:caption]
    end
    if @params[:question][id].has_key? :required
      @question.required = @params[:question][id][:required]
    end
    @question.save
    
    @page = @question.page
    render :partial => "editquestion", :locals => { :question => @question }
  end
  
  def change_range_params
    id = @params[:id]
    @question = Question.find(id)
    @question.min = @params[:question][id][:min]
    @question.max = @params[:question][id][:max]
    @question.step = @params[:question][id][:step]
    @question.save
    
    @page = @question.page
    render :partial => "editquestion", :locals => { :question => @question }
  end
  
  def delete_response
    Response.delete(@params[:id])
    render :nothing => true
  end
end
