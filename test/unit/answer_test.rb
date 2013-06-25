require 'test_helper'

class AnswerTest < ActiveSupport::TestCase  
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
end