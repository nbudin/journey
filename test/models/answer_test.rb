require 'test_helper'

class AnswerTest < ActiveSupport::TestCase
  describe "An answer to a question that has been responded to multiple times" do
    before do
      @question = FactoryGirl.create(:text_field)
      @questionnaire = @question.page.questionnaire
      
      @responses = (1..5).map do |n|
        FactoryGirl.create(:response, :questionnaire => @questionnaire)
      end
      @answers = @responses.map do |resp|
        FactoryGirl.create(:answer, :response => resp, :question => @question)
      end
      
      assert_equal 5, @responses.size
      assert_equal 5, @answers.size
      assert_equal 5, @questionnaire.responses.reload.size
      
      @response = @responses.last
      @answer = @answers.last
    end
    
    it "should return the corresponding answer" do
      assert_equal @answer, Answer.find_answer(@response, @question)
    end
  end
  
  describe "An answer to a freeform field" do
    before do 
      @answer = FactoryGirl.create(:answer, :question => FactoryGirl.create(:text_field), :value => "something")
    end
    
    it "should return both the value and output value as the same" do
      assert_equal "something", @answer.value
      assert_equal "something", @answer.output_value
    end
  end
  
  describe "An answer to a selector field with output values" do
    before do
      @question = FactoryGirl.create(:radio_field)
      @question.question_options.create :option => "male", :output_value => "M"
      @question.question_options.create :option => "female", :output_value => "F"
      @answer = FactoryGirl.create(:answer, :question => @question, :value => "male")
    end
    
    it "should return the output value" do
      assert @answer.question.reload.kind_of? Questions::SelectorField
      assert @answer.question.question_options.any? { |opt| opt.option == @answer.value }
      assert_equal "M", @answer.output_value
    end
    
    it "should return the correct input value" do
      assert_equal "male", @answer.value
    end
  end
  
  describe "An answer to a selector field without output values" do
    before do
      @question = FactoryGirl.create(:drop_down_field)
      %w{Burger Fries Coke}.each { |o| @question.question_options.create :option => o }
      @answer = FactoryGirl.create(:answer, :question => @question, :value => 'Burger')
    end
    
    it "should have the same output value as its actual value" do
      assert_equal @answer.value, @answer.output_value
    end
  end
  
  describe "An answer to a check box field" do
    before do
      @question = FactoryGirl.create(:check_box_field)
      @answer = FactoryGirl.create(:answer, :question => @question)
    end
    
    it "should say 'false' for its value and output value if the value is nil" do
      @answer.update_attributes(value: nil)
      assert_equal "false", @answer.value
      assert_equal "false", @answer.output_value
    end

    it "should say 'true' for its value and output value if the value is non-nil" do
      ["true", 1, "false"].each do |value|
        @answer.update_attributes(value: value)
        assert_equal "true", @answer.value
        assert_equal "true", @answer.output_value
      end
    end
  end
end