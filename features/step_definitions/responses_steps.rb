Given /^(\d+) responses to "([^\"]*)"$/ do |n, title|
  questionnaire = Questionnaire.first(:conditions => {:title => title})
  n.to_i.times do
    r = questionnaire.responses.create
    questionnaire.fields.each do |field|
      a = r.answers.new :question => field
      if field.is_a? Questions::FreeformField
        a.value = (0...(Kernel.rand(10) + 10)).collect { (45..126).to_a[Kernel.rand(81)].chr }.join
      else
        a.value = field.question_options[Kernel.rand(field.question_options.size)].value
      end
      a.save
    end
  end
end

Then /^I should see (\d+) responses$/ do |n|
  assert_equal(n.to_i, page.all('#responsetable tr td:first-child a').size)
end

When /^I open response \#(\d+)$/ do |i|
  page.all('#responsetable tr td:first-child a')[i.to_i - 1].click
end