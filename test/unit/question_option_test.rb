require File.dirname(__FILE__) + '/../test_helper'

class QuestionOptionTest < ActiveSupport::TestCase
  fixtures :question_options
  
  # Replace this with your real tests.
  def test_truth
    assert_kind_of QuestionOption, question_options(:burger)
  end
end
