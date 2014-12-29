require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  test "special field purposes should set and unset correctly" do
    question = FactoryGirl.create(:question, purpose: "name")
    assert_equal "name", question.reload.purpose
    
    question.update_attributes(purpose: nil)
    assert_nil question.reload.purpose
  end  
end
