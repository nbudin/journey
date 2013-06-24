FactoryGirl.define do
  factory :response do
    questionnaire
    
    factory :randomized_response do
      after(:build) do |response|
        response.questionnaire.fields.each do |field|
          answer = response.answers.new :question => field          
          answer.value = case field
          when Questions::FreeformField
            (0...(Kernel.rand(10) + 10)).collect { (45..126).to_a[Kernel.rand(81)].chr }.join
          else
            field.question_options[Kernel.rand(field.question_options.size)].value
          end
        end
      end
    end
  end
end