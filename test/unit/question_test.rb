require File.dirname(__FILE__) + '/../test_helper'

class QuestionTest < ActiveSupport::TestCase
  should belong_to(:page)
  should have_one(:special_field_association)
  should have_many(:question_options)
  should have_many(:answers)
end
