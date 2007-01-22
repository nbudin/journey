require File.dirname(__FILE__) + '/../test_helper'

class QuestionOptionTest < Test::Unit::TestCase
  fixtures :question_options

  # Replace this with your real tests.
  def test_truth
    assert_kind_of QuestionOption, question_options(:first)
  end
end
