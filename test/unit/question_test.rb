require File.dirname(__FILE__) + '/../test_helper'

class QuestionTest < ActiveSupport::TestCase
  should_belong_to :page
  should_have_one :special_field_association
  should_have_many :question_options
  should_have_many :answers
  
  context "A newly created Question" do
    setup do
      @question = Question.create
    end
    
    should "have a title containing 'click here'" do
      assert_match /click here/i, @question
    end
  end
end
