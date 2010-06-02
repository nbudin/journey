def email_address_from_name(firstname, lastname)
  "#{firstname.downcase}.#{lastname.downcase}@example.com"
end

def password_from_name(firstname, lastname)
  "MyNameIs#{firstname}#{lastname}"
end

Then /^I should be logged in$/ do
  assert session[:person]
end

Then /^I should be logged in as (.*) (.*)$/ do |firstname, lastname|
  person = Person.find_by_firstname_and_lastname(firstname, lastname)
  assert_equal person.id, session[:person]
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
  Given "I am on the home page"
  unless controller.logged_in?
    Given "I am on the login page"
    And "I fill in \"Email address\" with \"#{email_address_from_name(firstname, lastname)}\""
    And "I choose \"Yes, my password is:\""
    And "I fill in \"login[password]\" with \"#{password_from_name(firstname, lastname)}\""
    And "I press \"Log in\""
    Then "I should be logged in as #{firstname} #{lastname}"
  end
end

Given /^I am logged in as (.*) (.*)$/ do |firstname, lastname|
  Given "the user #{firstname} #{lastname} exists"
  And "I log in as #{firstname} #{lastname}"
end