require File.dirname(__FILE__) + '/../test_helper'

class QuestionTest < ActiveSupport::TestCase
  should_belong_to :page
  should_have_one :special_field_association
  should_have_many :question_options
end
