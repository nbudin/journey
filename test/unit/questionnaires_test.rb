require File.dirname(__FILE__) + '/../test_helper'

class QuestionnairesTest < Test::Unit::TestCase
  fixtures :questionnaires

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Questionnaires, questionnaires(:first)
  end
end
