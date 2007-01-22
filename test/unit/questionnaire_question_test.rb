require File.dirname(__FILE__) + '/../test_helper'

class QuestionnaireQuestionTest < Test::Unit::TestCase
  fixtures :questionnaire_questions

  # Replace this with your real tests.
  def test_truth
    assert_kind_of QuestionnaireQuestion, questionnaire_questions(:first)
  end
end
