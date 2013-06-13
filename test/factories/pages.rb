FactoryGirl.define do
  sequence :page_title do |n|
    "Page #{n}"
  end

  factory :page do
    title { FactoryGirl.generate :page_title }
    questionnaire
  end
end