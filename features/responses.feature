Feature: Manage responses

  Scenario: View responses
    Given the basic questionnaire
    And 3 responses to "Basic questionnaire"
    
    When I am logged in as Joe User
    And Joe User owns the questionnaire "Basic questionnaire"
    And I go to the responses page for "Basic questionnaire"
    Then I should see 3 responses
