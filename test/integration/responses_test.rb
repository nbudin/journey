require 'test_helper'

class ResponsesTest < ActionDispatch::IntegrationTest
  before do
    @person = FactoryGirl.create(:person)
    
    @questionnaire = FactoryGirl.create(:basic_questionnaire)
    @questionnaire.questionnaire_permissions.create(person: @person, all_permissions: true)
    @responses = (1..3).map { FactoryGirl.create(:randomized_response, questionnaire: @questionnaire) }
    
    Capybara.current_driver = Capybara.javascript_driver
    login_as @person, scope: :person, run_callbacks: false
  end
  
  test 'see all responses' do
    visit questionnaire_responses_path(@questionnaire)

    @responses.each do |response|
      within("table#responsetable") do
        assert has_content?("Response ID##{response.id}")
        
        within("tr", text: "Response ID##{response.id}") do
          click_link "View response"
        end
      end
        
      within "#responseviewer" do
        response.answers.each do |answer|
          assert has_content?(answer.value)
        end
      end
    end
  end
  
  test 'modify notes for a response' do
    visit questionnaire_responses_path(@questionnaire)
    response = @responses.first

    within("table#responsetable tr", text: "Response ID##{response.id}") do
      click_link "View response"
    end
      
    within "#responseviewer" do
      click_button "Edit"
      
      fill_in "Notes", with: "This person is a goofball.  Ignore their response."
      click_button "Save"
    end
    
    assert has_content?("This person is a goofball.  Ignore their response.")
    assert_equal "This person is a goofball.  Ignore their response.", response.reload.notes
  end
end
