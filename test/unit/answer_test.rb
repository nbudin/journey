require File.dirname(__FILE__) + '/../test_helper'

class AnswerTest < ActiveSupport::TestCase
  fixtures :questions, :question_options
  
  should belong_to(:question)
  should belong_to(:response)
  
  context "An answer to a selector field with output values" do
    setup do
      @answer = Answer.create :question => questions(:radio_field), :value => "male"
    end
    
    should "return the output value" do
      assert @answer.question.kind_of? Questions::SelectorField
      assert @answer.question.question_options.any? { |opt| opt.value == @answer.value }
      assert_equal "M", @answer.output_value
    end
    
    should "return the correct input value" do
      assert_equal "male", @answer.value
    end
  end
  
  context "An answer to a selector field without output values" do
    setup do
      @answer = Answer.create :question => questions(:drop_down_field), :value => 'Burger'
    end
    
    should "have the same output value as its actual value" do
      assert_equal @answer.value, @answer.output_value
    end
  end
end