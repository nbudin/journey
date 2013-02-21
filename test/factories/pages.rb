Factory.sequence :page_title do |n|
  "Page #{n}"
end

Factory.define :page do |p|
  p.title { Factory.next :page_title }
  p.association :questionnaire
end