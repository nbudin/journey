require File.dirname(__FILE__) + '/../test_helper'

class ResponseTest < ActiveSupport::TestCase
  should belong_to(:questionnaire)
  should belong_to(:person)
  should have_many(:answers)
end
