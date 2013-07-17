FactoryGirl.define do
  factory :questionnaire do
    title "A questionnaire"
    
    factory :basic_questionnaire do
      title "Basic questionnaire"
      pages { [FactoryGirl.build(:basic_questionnaire_page1)] }
    end

    factory :comprehensive_questionnaire do
      after(:build) do |questionnaire|
        questionnaire.pages << FactoryGirl.build(:page, questionnaire: questionnaire, title: "First page")
        questionnaire.pages << FactoryGirl.build(:page, questionnaire: questionnaire, title: "Last page")
    
        page1 = questionnaire.pages.first
        %w(big_text_field divider heading label check_box_field text_field range_field).each do |question_type|
          page1.questions << FactoryGirl.build(question_type, page: page1, caption: question_type.humanize)
        end

        %w(radio_field drop_down_field).each do |question_type|
          question = FactoryGirl.build(question_type, page: page1, caption: question_type.humanize)
          3.times { |n| question.question_options << FactoryGirl.build(:question_option, question: question, option: "Option #{n+1}") }
          page1.questions << question
        end        
        
        page2 = questionnaire.pages.last
        Questionnaire.special_field_purposes.each do |purpose|
          page2.questions << FactoryGirl.build(:text_field, page: page2, caption: purpose.humanize, purpose: purpose)
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