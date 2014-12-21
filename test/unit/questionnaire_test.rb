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
      q1 = Questions::TextField.create(:page => page1, :caption => "Who?", :position => 1, :purpose => "name")
      q2 = Questions::TextField.create(:page => page1, :caption => "Wherefore?", :position => 2)
      
      page2 = @questionnaire.pages.create(:position => 2)
      q3 = Questions::Label.create(:page => page2, :caption => "Because.", :position => 1)
      q4 = Questions::TextField.create(:page => page2, :caption => "But really, why?", :position => 2)
      q5 = Questions::Label.create(:page => page2, :caption => "Read on for the chilling conclusion!", :position => 3)
      
      page3 = @questionnaire.pages.create(:position => 3)
      q6 = Questions::TextField.create(:page => page3, :caption => "You got something to say, punk?", :position => 1)
      q7 = Questions::Label.create(:page => page3, :caption => "I'm not telling you.", :position => 2)
      q8 = Questions::RadioField.create(:page => page3, :caption => "What does the fox say?", :position => 3)
      q8.question_options.create(option: "Ring-ding-ding-ding-dingeringeding!")
      q8.question_options.create(option: "Wa-pa-pa-pa-pa-pa-pow!", output_value: "correct answer")
      q8.question_options.create(option: "Hatee-hatee-hatee-ho!")
      
      @questions  = [q1, q2, q3, q4, q5, q6, q7, q8]
      @fields     = [q1, q2, q4, q6, q8]
      @decorators = [q3, q5, q7]
    end
    
    it "should return all questions in the right order" do
      assert_equal @questions, @questionnaire.questions.to_a
    end
    
    it "should return all fields in the right order" do
      assert_equal @fields, @questionnaire.fields.to_a
    end
    
    it "should return all decorators in the right order" do
      assert_equal @decorators, @questionnaire.decorators.to_a
    end
    
    it "should deepclone to an entirely new questionnaire" do
      clone = @questionnaire.deepclone
      clone.save!
      
      @questionnaire.pages.each_with_index do |page, i|
        cloned_page = clone.pages[i]
        assert cloned_page.persisted?
        assert_equal page.title, cloned_page.title
        assert_equal page.position, cloned_page.position
        assert_not_equal page.id, cloned_page.id
        assert cloned_page.id.present?
      end
      
      @questions.each_with_index do |question, i|
        cloned_question = clone.questions[i]
        assert cloned_question.persisted?
        assert_equal question.caption, cloned_question.caption
        assert_equal question.type, cloned_question.type
        assert_equal question.purpose, cloned_question.purpose
        assert_not_equal question.id, cloned_question.id
        assert cloned_question.id.present?

        if question.special_field_association
          assert_not_equal question.special_field_association.id, cloned_question.special_field_association.id
        end

        question.question_options.each_with_index do |question_option, j|
          cloned_option = cloned_question.question_options[j]
          assert cloned_option.persisted?
          assert_equal question_option.option, cloned_option.option
          assert_equal question_option.output_value, cloned_option.output_value
        end
      end
    end
    
    describe "and responses" do
      before do
        @answer_sets = (1..3).map do |i|
          @fields.each_with_index.map do |field, j|
            case field
            when Questions::FreeformField then "Question #{j} answer #{i}"
            when Questions::SelectorField then field.question_options[(i + j) % field.question_options.size].option
            end
          end
        end
        
        @responses = @answer_sets.map do |answer_set|
          @questionnaire.responses.create.tap do |response|
            @fields.zip(answer_set).map do |(field, answer_value)|
              response.answers.create(question: field, value: answer_value)
            end
            response.update_attributes(submitted_at: Time.now)
          end
        end
      end
      
      it "doesn't copy the responses to a deepclone by default" do
        clone = @questionnaire.deepclone
        clone.save!
        
        assert_equal 0, clone.responses.size
      end
      
      it "copies the responses to a deepclone correctly" do
        clone = @questionnaire.deepclone(true)
        clone.save!
        
        @questionnaire.responses.zip(clone.responses).each do |(response, cloned_response)|
          assert cloned_response.persisted?
          assert_not_equal response.id, cloned_response.id
          assert_not_equal response.created_at, cloned_response.created_at
          assert_equal response.submitted_at, cloned_response.submitted_at
          
          response.answers.zip(cloned_response.answers).each do |(answer, cloned_answer)|
            assert cloned_answer.persisted?
            binding.pry if answer.id == cloned_answer.id
            assert_not_equal answer.id, cloned_answer.id
            assert_equal answer.question.caption, cloned_answer.question.caption
            assert_equal answer.value, cloned_answer.value
            assert_equal answer.output_value, cloned_answer.output_value
          end
        end
      end
    end
  end
end
