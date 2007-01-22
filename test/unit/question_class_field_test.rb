require File.dirname(__FILE__) + '/../test_helper'

class QuestionClassFieldTest < Test::Unit::TestCase
  fixtures :question_class_fields

  # Replace this with your real tests.
  def test_truth
    assert_kind_of QuestionClassField, question_class_fields(:first)
  end
end
