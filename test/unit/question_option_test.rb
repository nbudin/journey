require File.dirname(__FILE__) + '/../test_helper'

class QuestionOptionTest < ActiveSupport::TestCase
  should_belong_to :question
end
