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
  person = Person.find(:first, :conditions => {:firstname => firstname, :lastname => lastname})
  person ||= Person.create!(:firstname => firstname, :lastname => lastname)
  assert person.account ||= person.create_account(:active => true,
    :password => password_from_name(firstname, lastname))
  
  EmailAddress.delete_all(:address => email_address_from_name(firstname, lastname))
  person.email_addresses.create!(:primary => true,
    :address => email_address_from_name(firstname, lastname))
end

Given /^I log in as (.*) (.*)$/ do |firstname, lastname|
  step "I am on the home page"
  unless page.has_content?("Log out")
    step "I am on the login page"
    step "I fill in \"Email address\" with \"#{email_address_from_name(firstname, lastname)}\""
    step "I choose \"Yes, my password is:\""
    step "I fill in \"login[password]\" with \"#{password_from_name(firstname, lastname)}\""
    step "I press \"Log in\""
    step "I should be logged in as #{firstname} #{lastname}"
  end
end

Given /^I am logged in as (.*) (.*)$/ do |firstname, lastname|
  step "the user #{firstname} #{lastname} exists"
  step "I log in as #{firstname} #{lastname}"
end