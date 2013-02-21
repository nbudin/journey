Factory.define :answer do |a|
  a.association :question
  a.association :response
end