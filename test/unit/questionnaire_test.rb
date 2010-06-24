require File.dirname(__FILE__) + '/../test_helper'

class QuestionnaireTest < ActiveSupport::TestCase
  fixtures :questionnaires
  
  should have_many(:pages)
  should have_many(:questions).through(:pages)
  should have_many(:fields).through(:pages)
  should have_many(:decorators).through(:pages)
  
  should have_many(:responses)
  should have_many(:special_field_associations)
  should have_many(:special_fields).through(:special_field_associations)
  
  context "A newly created Questionnaire" do
    setup do
      @questionnaire = Questionnaire.create
    end
    
    should "have the title 'untitled'" do
      assert_match /untitled/i, @questionnaire.title
    end
    
    should "have a page to start with" do
      assert @questionnaire.pages.count == 1
    end
  end
end
