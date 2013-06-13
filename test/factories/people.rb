FactoryGirl.define do
  sequence :username do |n|
    "user#{n}"
  end
  
  factory :person do
    firstname "Firstname"
    lastname "Lastname"
    username { FactoryGirl.generate :username }
  end
end