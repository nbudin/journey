require File.dirname(__FILE__) + '/../test_helper'

class QuestionOptionTest < ActiveSupport::TestCase
  should belong_to(:question)
end
