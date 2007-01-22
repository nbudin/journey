require File.dirname(__FILE__) + '/../test_helper'

class QuestionAttrTest < Test::Unit::TestCase
  fixtures :question_attrs

  # Replace this with your real tests.
  def test_truth
    assert_kind_of QuestionAttr, question_attrs(:first)
  end
end
