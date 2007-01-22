require File.dirname(__FILE__) + '/../test_helper'

class QuestionClassAttrTest < Test::Unit::TestCase
  fixtures :question_class_attrs

  # Replace this with your real tests.
  def test_truth
    assert_kind_of QuestionClassAttr, question_class_attrs(:first)
  end
end
