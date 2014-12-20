require 'test_helper'

class QuestionnaireAnsweringTest < ActionDispatch::IntegrationTest
  ANSWERS = { 
    "Big text field" => "This is my life story.\nIt hasn't been a long life.",
    "Text field" => "A shorter story.",
    "Range field" => "3",
    "Radio field" => "Option 3",
    "Drop down field" => "Option 2",
    "Name" => "Jenny Jenny",
    "Phone" => "867-5309",
    "Gender" => "female",
    "Address" => "Tommy Tutone's Place",
    "Email" => "jenny.jenny@msn.com"
  }
  
  before do
    Capybara.current_driver = Capybara.javascript_driver
    @questionnaire = FactoryGirl.create(:comprehensive_questionnaire, is_open: true)
  end
  
  test 'logged out' do
    visit questionnaire_answer_path(@questionnaire)    
    click_on "Answer this survey without logging in"
    
    fill_in_page1
    click_on "Next page"
    
    fill_in_page2
    
    click_button "Previous page"
    verify_page1
    
    click_button "Next page"
    verify_page2
    
    click_button "Finish"
    assert has_content?("Thank you!")
    
    verify_response
  end
  
  test 'logged in' do
    @person = FactoryGirl.create(:person, email: "firstname@lastname.com", gender: "fluid")
    login_as @person, scope: :person, run_callbacks: false
    
    visit questionnaire_answer_path(@questionnaire)
    assert has_content?("Welcome, Firstname Lastname!")
    
    click_on "Start survey"
    
    fill_in_page1
    click_on "Next page"
    
    assert_equal "Firstname Lastname", find_field("Name").value
    assert_equal "firstname@lastname.com", find_field("Email").value
    assert_equal "fluid", find_field("Gender").value
    
    fill_in_page2
    
    click_button "Previous page"
    verify_page1
    
    click_button "Next page"
    verify_page2
    
    click_button "Finish"
    assert has_content?("Thank you!")
    
    verify_response
  end
  
  private
  
  def fill_in_page1
    assert has_content?("First page")
    assert has_content?("Page 1 of 2")
    
    fill_in_freeforms "Big text field", "Text field"
    
    assert has_content?("Heading")
    assert has_content?("Label")
    
    check "Check box field"
    within(".question.layout-left", text: "Range field") { find(%(input[type=radio][value="#{ANSWERS["Range field"]}"])).click }
    choose ANSWERS["Radio field"]
    select ANSWERS["Drop down field"], from: "Drop down field"
  end
  
  def verify_page1
    verify_field_values "Big text field", "Text field", "Drop down field"
    assert find_field("Check box field").checked?
    within(".question.layout-left", text: "Range field") { assert find(%(input[type=radio][value="#{ANSWERS["Range field"]}"])).checked? }
    within(".question.layout-left", text: "Radio field") { assert find(%(input[type=radio][value="#{ANSWERS["Radio field"]}"])).checked? }
  end
  
  def fill_in_page2
    assert has_content?("Last page")
    assert has_content?("Page 2 of 2")
    
    fill_in_freeforms "Name", "Phone", "Gender", "Address", "Email"
  end
  
  def verify_page2
    verify_field_values "Name", "Phone", "Gender", "Address", "Email"
  end
  
  def fill_in_freeforms(*field_names)
    field_names.each { |field_name| fill_in field_name, with: ANSWERS[field_name] }
  end
  
  def verify_field_values(*field_names)
    field_names.each { |field_name| assert_equal ANSWERS[field_name], find_field(field_name).value, "Expected #{field_name} to have value #{ANSWERS[field_name]}"}
  end
  
  def verify_response
    assert_equal 1, Response.count
    resp = Response.first
    
    ANSWERS.each do |field_name, value|
      question = @questionnaire.questions.find_by(caption: field_name)
      assert_equal value, resp.answer_for_question(question).value.gsub(/\r\n/, "\n")
    end
  end
end