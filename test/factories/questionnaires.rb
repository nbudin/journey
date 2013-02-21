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

Factory.define :comprehensive_questionnaire, :parent => :questionnaire do |q|
  q.after_build do |questionnaire|
    questionnaire.pages << Factory.build(:page)
    questionnaire.pages << Factory.build(:page)
    
    page1 = questionnaire.pages.first
    %w(big_text_field divider heading label check_box_field text_field range_field).each do |question_type|
      page1.questions << Factory.build(question_type)
    end

    %w(radio_field drop_down_field).each do |question_type|
      question = Factory.build(question_type)
      3.times { question.question_options << Factory.build(:question_option) }
      page1.questions << question
    end
  end
end