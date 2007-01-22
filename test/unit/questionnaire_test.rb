require File.dirname(__FILE__) + '/../test_helper'

class QuestionnaireTest < Test::Unit::TestCase
  fixtures :questionnaires

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Questionnaire, questionnaires(:first)
  end
end
