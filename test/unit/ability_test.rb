require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  before do
    @person = FactoryGirl.create :person
    @ability = Ability.new(@person)
  end
  
  it "should let me create questionnaires" do
    assert @ability.can?(:create, Questionnaire)
  end
  
  describe "on a questionnaire" do
    before do
      @questionnaire = FactoryGirl.create :comprehensive_questionnaire
      @page = @questionnaire.pages.first
      @question = @questionnaire.questions.first
      @question_option = @questionnaire.fields.select { |f| f.question_options.any? }.first.question_options.first
      
      @response = FactoryGirl.create :randomized_response, questionnaire: @questionnaire
    end
    
    it "should let the owner do everything" do
      @questionnaire.questionnaire_permissions.create(person: @person, all_permissions: true)
      [:read, :update, :destroy, :view_answers, :change_permissions].each { |action| assert @ability.can?(action, @questionnaire) }      
      [:read, :create, :update, :destroy].each { |action| assert @ability.can?(action, @page) }
      [:read, :create, :update, :destroy].each { |action| assert @ability.can?(action, @question) }
      [:read, :create, :update, :destroy].each { |action| assert @ability.can?(action, @question_option) }
      [:read, :create, :update, :destroy].each { |action| assert @ability.can?(action, @response) }
    end
    
    it "should let editors mess with the questionnaire itself but not the responses" do
      @questionnaire.questionnaire_permissions.create(person: @person, can_edit: true)
      
      [:read, :update].each { |action| assert @ability.can?(action, @questionnaire) }      
      [:destroy, :view_answers, :change_permissions].each { |action| assert !@ability.can?(action, @questionnaire) }      
      [:read, :create, :update, :destroy].each { |action| assert @ability.can?(action, @page) }
      [:read, :create, :update, :destroy].each { |action| assert @ability.can?(action, @question) }
      [:read, :create, :update, :destroy].each { |action| assert @ability.can?(action, @question_option) }
      [:read, :create, :update, :destroy].each { |action| assert !@ability.can?(action, @response) }      
    end
    
    it "should let destroyers destroy the questionnaire but not do much else" do
      @questionnaire.questionnaire_permissions.create(person: @person, can_destroy: true)
      
      [:read, :destroy].each { |action| assert @ability.can?(action, @questionnaire) }      
      [:update, :view_answers, :change_permissions].each { |action| assert !@ability.can?(action, @questionnaire) }      
      [:read, :create, :update, :destroy].each { |action| assert !@ability.can?(action, @page) }
      [:read, :create, :update, :destroy].each { |action| assert !@ability.can?(action, @question) }
      [:read, :create, :update, :destroy].each { |action| assert !@ability.can?(action, @question_option) }
      [:read, :create, :update, :destroy].each { |action| assert !@ability.can?(action, @response) }      
    end
    
    it "should let answer viewers view answers but not do much else" do
      @questionnaire.questionnaire_permissions.create(person: @person, can_view_answers: true)
      
      [:read, :view_answers].each { |action| assert @ability.can?(action, @questionnaire) }      
      [:update, :destroy, :change_permissions].each { |action| assert !@ability.can?(action, @questionnaire) }      
      [:read, :create, :update, :destroy].each { |action| assert !@ability.can?(action, @page) }
      [:read, :create, :update, :destroy].each { |action| assert !@ability.can?(action, @question) }
      [:read, :create, :update, :destroy].each { |action| assert !@ability.can?(action, @question_option) }
      [:read].each { |action| assert @ability.can?(action, @response) }
      [:create, :update, :destroy].each { |action| assert !@ability.can?(action, @response) }      
    end
    
    it "should let answer editors view answers but not do much else" do
      @questionnaire.questionnaire_permissions.create(person: @person, can_edit_answers: true)
      
      [:read, :view_answers].each { |action| assert @ability.can?(action, @questionnaire) }      
      [:update, :destroy, :change_permissions].each { |action| assert !@ability.can?(action, @questionnaire) }      
      [:read, :create, :update, :destroy].each { |action| assert !@ability.can?(action, @page) }
      [:read, :create, :update, :destroy].each { |action| assert !@ability.can?(action, @question) }
      [:read, :create, :update, :destroy].each { |action| assert !@ability.can?(action, @question_option) }
      [:read, :create, :update, :destroy].each { |action| assert @ability.can?(action, @response) }
    end
    
    it "should let permission admins change permissions but not do much else" do
      @questionnaire.questionnaire_permissions.create(person: @person, can_change_permissions: true)
      
      [:read, :change_permissions].each { |action| assert @ability.can?(action, @questionnaire) }      
      [:view_answers, :update, :destroy].each { |action| assert !@ability.can?(action, @questionnaire) }      
      [:read, :create, :update, :destroy].each { |action| assert !@ability.can?(action, @page) }
      [:read, :create, :update, :destroy].each { |action| assert !@ability.can?(action, @question) }
      [:read, :create, :update, :destroy].each { |action| assert !@ability.can?(action, @question_option) }
      [:read, :create, :update, :destroy].each { |action| assert !@ability.can?(action, @response) }
    end
    
    it "should let the general public destroy their own responses" do
      [:read, :view_answers, :update, :destroy, :change_permissions].each { |action| assert !@ability.can?(action, @questionnaire) }      
      [:read, :create, :update, :destroy].each { |action| assert !@ability.can?(action, @page) }
      [:read, :create, :update, :destroy].each { |action| assert !@ability.can?(action, @question) }
      [:read, :create, :update, :destroy].each { |action| assert !@ability.can?(action, @question_option) }
      [:read, :create, :update, :destroy].each { |action| assert !@ability.can?(action, @response) }
      
      my_response = FactoryGirl.create(:randomized_response, questionnaire: @questionnaire, person: @person)
      assert @ability.can?(:destroy, my_response)
    end
    
    it "should let the general public read open, public questionnaires" do
      @questionnaire.update_attributes(is_open: true, publicly_visible: true)
      assert @ability.can?(:read, @questionnaire)
    end
  end  
end
