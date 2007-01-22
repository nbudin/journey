require File.dirname(__FILE__) + '/../test_helper'

class ReturnAnswerTest < Test::Unit::TestCase
  fixtures :return_answers

  # Replace this with your real tests.
  def test_truth
    assert_kind_of ReturnAnswer, return_answers(:first)
  end
end
