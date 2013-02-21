Factory.define :question do |q|
  q.caption "What is the answer to this question?"
  q.association :page
end

Factory.define :radio_field, :parent => :question do |q|
  q.type "Questions::RadioField"
end

Factory.define :text_field, :parent => :question do |q|
  q.type "Questions::TextField"
end

Factory.define :big_text_field, :parent => :question do |q|
  q.type "Questions::BigTextField"
end

Factory.define :drop_down_field, :parent => :question do |q|
  q.type "Questions::DropDownField"
end

Factory.define :range_field, :parent => :question do |q|
  q.type "Questions::RangeField"
  q.min 1
  q.max 5
end

Factory.define :check_box_field, :parent => :question do |q|
  q.type "Questions::CheckBoxField"
end

Factory.define :heading, :parent => :question do |q|
  q.type "Questions::Heading"
end

Factory.define :label, :parent => :question do |q|
  q.type "Questions::Label"
end

Factory.define :divider, :parent => :question do |q|
  q.type "Questions::Divider"
end