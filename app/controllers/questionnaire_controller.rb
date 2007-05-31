require "sha1"

class QuestionnaireController < ApplicationController
  def new
    @editing = false
  end
  
  def index
  end
  
  def create_questionnaire
    @questionnaire = Questionnaire.create(params[:questionnaire])
    redirect_to :action => 'index'
  end
  
  def delete
    @questionnaire = Questionnaire.find(params[:id])
    if params[:confirm]
      qname = @questionnaire.title
      @questionnaire.destroy
      @flash[:notice] = "Questionnaire \"#{qname}\" deleted."
      redirect_to :action => 'index'
    end
  end
  
  def edit
    @questionnaire = Questionnaire.find(params[:id])
  end
  
  def set_open
    @questionnaire = Questionnaire.find(params[:id])
    @questionnaire.is_open = (params[:status] == 'open')
    @questionnaire.save
    
    redirect_to :action => 'index'
  end
  
  def change_questionnaire_params
    @questionnaire = Questionnaire.find(params[:id])
    @questionnaire.update_attributes(params[:questionnaire][params[:id]])
    @questionnaire.save
    
    redirect_to :action => 'edit', :id => @questionnaire.id
  end
  
  def add_page_to_questionnaire
    @questionnaire = Questionnaire.find(params[:id])
    @page = Page.create :questionnaire_id => @questionnaire.id
    @page.insert_at(params[:position])
    
    redirect_to :action => 'edit', :id => @questionnaire.id
  end
  
  def delete_page
    @questionnaire = Page.find(params[:id]).questionnaire
    html = render :action => 'edit'
    
    Page.delete(params[:id])
    return html
  end
  
  def change_page_title
    @page = Page.find(params[:id])
    @page.title = params[:page][params[:id]][:title]
    @page.save
    
    @questionnaire = @page.questionnaire
    render :action => 'edit'
  end
  
  def add_question_to_page
    @page = Page.find(params[:id])
    @question = Question.new
    @question.page_id = @page.id
    @question.type = 'Question'
    @question.save
    @question.insert_at(params[:position])
    
    @questionnaire = @page.questionnaire
    render :partial => "editpage"
  end
  
  def delete_question
    @page = Question.find(params[:id]).page
    @questionnaire = @page.questionnaire
    html = render :partial => "editpage"

    Question.delete(params[:id])
    return html
  end
  
  def change_question_type
    @question = Question.find(params[:id])
    @question.update_attribute(:type, params[:type])
    @question.save
    
    @question = Question.find(params[:id])
    @page = @question.page
    render :partial => "editquestion", :locals => { :question => @question }
  end
  
  def change_field_purpose
    @question = Question.find(params[:id])
    if not params[:purpose].empty?
      if @question.special_field_association.nil?
        @question.create_special_field_association :questionnaire => @question.questionnaire,
          :purpose => params[:purpose]
      else
        sfa = @question.special_field_association
        sfa.purpose = params[:purpose]
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
    option = QuestionOption.new :option => params[:option]
    @question = Question.find(params[:id])
    @question.question_options << option
    
    @page = @question.page
    render :partial => "editquestion", :locals => { :question => @question }
  end
  
  def remove_options_from_question
    QuestionOption.destroy(params[:options])
    
    @question = Question.find(params[:id])
    @page = @question.page
    render :partial => "editquestion", :locals => { :question => @question }
  end
  
  def change_default_answer
    id = params[:id]
    @question = Question.find(id)
    @question.default_answer = params[:question][id][:default_answer]
    @question.save
    
    @page = @question.page
    render :partial => "editquestion", :locals => { :question => @question }
  end
  
  def change_question_attrs
    id = params[:id]
    @question = Question.find(id)
    if params[:question][id].has_key? :caption
      @question.caption = params[:question][id][:caption]
    end
    if params[:question][id].has_key? :required
      @question.required = params[:question][id][:required]
    end
    @question.save
    
    @page = @question.page
    render :partial => "editquestion", :locals => { :question => @question }
  end
  
  def change_range_params
    id = params[:id]
    @question = Question.find(id)
    @question.min = params[:question][id][:min]
    @question.max = params[:question][id][:max]
    @question.step = params[:question][id][:step]
    @question.save
    
    @page = @question.page
    render :partial => "editquestion", :locals => { :question => @question }
  end
  
  def delete_response
    Response.delete(params[:id])
    render :nothing => true
  end
end
