require File.dirname(__FILE__) + '/../test_helper'

class ReturnTest < Test::Unit::TestCase
  fixtures :returns

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Return, returns(:first)
  end
end
