require 'test_helper'
require 'performance_test_help'

class SaveAnswersTest < ActionController::PerformanceTest
  def test_save_answers
    get '/'
  end
end
