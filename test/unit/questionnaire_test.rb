require 'test_helper'

class QuestionnaireTest < ActiveSupport::TestCase
  describe "A newly created Questionnaire" do
    before do
      @questionnaire = Questionnaire.create
    end
    
    it "should have the title 'untitled'" do
      assert_match /untitled/i, @questionnaire.title
    end
    
    it "should have a page to start with" do
      assert @questionnaire.pages.count == 1
    end
  end
  
  describe "A questionnaire with multiple pages" do
    before do
      @questionnaire = Questionnaire.create
      
      page1 = @questionnaire.pages.create(:position => 1)
      q1 = Questions::TextField.create(:page => page1, :caption => "Why?", :position => 1)
      q2 = Questions::TextField.create(:page => page1, :caption => "Wherefore?", :position => 2)
      
      page2 = @questionnaire.pages.create(:position => 2)
      q3 = Questions::Label.create(:page => page2, :caption => "Because.", :position => 1)
      q4 = Questions::TextField.create(:page => page2, :caption => "But really, why?", :position => 2)
      q5 = Questions::Label.create(:page => page2, :caption => "Read on for the chilling conclusion!", :position => 3)
      
      page3 = @questionnaire.pages.create(:position => 3)
      q6 = Questions::TextField.create(:page => page3, :caption => "You got something to say, punk?", :position => 1)
      q7 = Questions::Label.create(:page => page3, :caption => "I'm not telling you.", :position => 2)
      
      @questions  = [q1, q2, q3, q4, q5, q6, q7]
      @fields     = [q1, q2, q4, q6]
      @decorators = [q3, q5, q7]
    end
    
    it "should return all questions in the right order" do
      assert_equal @questions, @questionnaire.questions
    end
    
    it "should return all fields in the right order" do
      assert_equal @fields, @questionnaire.fields
    end
    
    it "should return all decorators in the right order" do
      assert_equal @decorators, @questionnaire.decorators
    end
  end
end
