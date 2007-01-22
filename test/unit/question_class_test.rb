require File.dirname(__FILE__) + '/../test_helper'

class QuestionClassTest < Test::Unit::TestCase
  fixtures :question_classes

  # Replace this with your real tests.
  def test_truth
    assert_kind_of QuestionClass, question_classes(:first)
  end
end
