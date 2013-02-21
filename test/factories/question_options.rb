Factory.sequence :question_option do |n|
  "Option #{n}"
end

Factory.define :question_option do |o|
  o.option { Factory.next :question_option }
  o.association :question
end