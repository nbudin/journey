Given /^the basic questionnaire$/ do
  Factory.create(:basic_questionnaire)
end

Given /^(.*) (.*) owns the questionnaire "([^\"]*)"$/ do |firstname, lastname, title|
  person = Person.find_by_firstname_and_lastname(firstname, lastname)
  questionnaire = Questionnaire.find_by_title(title)
  questionnaire.grant(person)
end