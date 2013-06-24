FactoryGirl.define do
  factory :questionnaire do
    title "A questionnaire"
    
    factory :basic_questionnaire do
      title "Basic questionnaire"
      pages { [FactoryGirl.build(:basic_questionnaire_page1)] }
    end

    factory :comprehensive_questionnaire do
      after(:build) do |questionnaire|
        questionnaire.pages << FactoryGirl.build(:page, questionnaire: questionnaire)
        questionnaire.pages << FactoryGirl.build(:page, questionnaire: questionnaire)
    
        page1 = questionnaire.pages.first
        %w(big_text_field divider heading label check_box_field text_field range_field).each do |question_type|
          page1.questions << FactoryGirl.build(question_type, page: page1)
        end

        %w(radio_field drop_down_field).each do |question_type|
          question = FactoryGirl.build(question_type, page: page1)
          3.times { question.question_options << FactoryGirl.build(:question_option) }
          page1.questions << question
        end
      end
    end
  end

  factory :basic_questionnaire_page1, :class => :page do
    title "The one and only page"
    questions do
      [Questions::TextField.new(:caption => "Name"),
       Questions::TextField.new(:caption => "Favorite color")]
    end
  end
end