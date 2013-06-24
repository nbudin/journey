def email_address_from_name(firstname, lastname)
  "#{firstname.downcase}.#{lastname.downcase}@example.com"
end

def password_from_name(firstname, lastname)
  "MyNameIs#{firstname}#{lastname}"
end

Then /^I should be logged in as (.*)$/ do |name|
  step "I should see \"#{name}\" within \".topbar .user_options\""
end

Given /^the user (.*) (.*) exists$/ do |firstname, lastname|
  email = email_address_from_name(firstname, lastname)
  person = Person.find(:first, :conditions => {:firstname => firstname, :lastname => lastname})
  person ||= FactoryGirl.create(:person, :firstname => firstname, :lastname => lastname, :email => email, :username => email)
end

Given /^I log in as (.*) (.*)$/ do |firstname, lastname|
  sign_in Person.find_by_username(email_address_from_name(firstname, lastname))
end

Given /^I am logged in as (.*) (.*)$/ do |firstname, lastname|
  step "the user #{firstname} #{lastname} exists"
  step "I log in as #{firstname} #{lastname}"
end