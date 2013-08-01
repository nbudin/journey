FactoryGirl.define do
  sequence :username do |n|
    "user#{n}"
  end
  
  sequence :email do |n|
    "user#{n}@example.com"
  end
  
  factory :person do
    firstname "Firstname"
    lastname "Lastname"
    username { FactoryGirl.generate :username }
    email { FactoryGirl.generate :email }
  end
end