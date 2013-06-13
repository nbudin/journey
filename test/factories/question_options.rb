FactoryGirl.define do
  sequence :question_option do |n|
    "Option #{n}"
  end

  factory :question_option do
    option { FactoryGirl.generate :question_option }
    question
  end
end