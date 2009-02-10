require File.dirname(__FILE__) + '/../test_helper'

class QuestionnaireTest < ActiveSupport::TestCase
  fixtures :questionnaires
  
  # Replace this with your real tests.
  def test_truth
    assert_kind_of Questionnaire, questionnaires(:comprehensive)
  end
end
