FactoryGirl.define do
  factory :response do
    questionnaire
    
    factory :randomized_response do
      after(:build) do |response|
        response.questionnaire.fields.each do |field|
          answer = response.answers.new :question => field          
          answer.value = case field
          when Questions::FreeformField
            (('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a).sample(Kernel.rand(10) + 10).join
          when Questions::CheckBoxField
            Kernel.rand(2) == 0 ? nil : true
          when Questions::RangeField
            Kernel.rand(field.max - field.min + 1) + field.min
          else
            field.question_options[Kernel.rand(field.question_options.size)].option
          end
        end
      end
    end
  end
end