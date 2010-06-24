Factory.define :questionnaire do |q|
  q.title "A questionnaire"
end

Factory.define :basic_questionnaire_page1, :class => :page do |p|
  p.title "The one and only page"
  p.questions do |p1|
    [Questions::TextField.new(:caption => "Name"),
     Questions::TextField.new(:caption => "Favorite color")]
  end
end

Factory.define :basic_questionnaire, :parent => :questionnaire do |bq|
  bq.title "Basic questionnaire"
  bq.pages do |q|
    [q.association(:basic_questionnaire_page1)]
  end
end
