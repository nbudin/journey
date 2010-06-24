Feature: Manage responses

  Scenario: View responses
    Given the basic questionnaire
    And 3 responses to "Basic questionnaire"
    
    When I am logged in as Joe User
    And Joe User owns the questionnaire "Basic questionnaire"
    And I go to the responses page for "Basic questionnaire"
    Then I should see 3 responses
    
  Scenario: Modify notes for a response
    Given the basic questionnaire
    And 3 responses to "Basic questionnaire"
    
    When I am logged in as Joe User
    And Joe User owns the questionnaire "Basic questionnaire"
    When I go to the response editing page for response #1 for "Basic questionnaire"
    And I fill in "Notes" with "This person is a goofball. Ignore their response."
    And I press "Save changes"
    
    Then I should be on the response page for response #1 for "Basic questionnaire"
    And I should see "This person is a goofball. Ignore their response."
    
    When I go to the response editing page for response #1 for "Basic questionnaire"
    And I fill in "Notes" with ""
    And I press "Save changes"
    
    Then I should be on the response page for response #1 for "Basic questionnaire"
    And I should not see "This person is a goofball. Ignore their response."
