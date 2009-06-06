require File.dirname(__FILE__) + '/../test_helper'

class ResponseTest < ActiveSupport::TestCase
  should_belong_to :questionnaire
  should_belong_to :person
  should_have_many :answers
end
