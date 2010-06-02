Factory.define :questionnaire do |q|
  q.title "A questionnaire"
end

Factory.define :basic_questionnaire_page1, :class => :page do |p|
  p.title "The one and only page"
  p.after_build do |p1|
    p1.questions << Questions::TextField.new(:page => p1, :caption => "Name")
    p1.questions << Questions::TextField.new(:page => p1, :caption => "Favorite color")
  end
end

Factory.define :basic_questionnaire, :parent => :questionnaire do |bq|
  bq.title "Basic questionnaire"
  bq.after_build do |q|
    q.pages << Factory.build(:basic_questionnaire_page1, :questionnaire => q)
  end
end