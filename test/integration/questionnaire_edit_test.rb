require 'test_helper'

class QuestionnaireEditTest < ActionDispatch::IntegrationTest
  before do
    @person = FactoryGirl.create(:person)
    
    Capybara.current_driver = Capybara.javascript_driver
    login_as @person, scope: :person, run_callbacks: false
    
    visit root_path
    click_link "Create, import, or copy"
    
    fill_in "Title:", with: "My new survey"
    click_button "Create"
    
    assert has_content?("My new survey")
    assert_equal 1, Questionnaire.count
    assert_equal questionnaire_path(Questionnaire.first), current_path
    
    @questionnaire = Questionnaire.first
    
    click_link "Edit"
  end
  
  test "creating special purpose questions and editing their properties" do
    within '#pages' do
      find('.page .caption').click
    end
    
    within_frame 'pageview' do
      assert has_content?("Add Fields")
      
      %w(Name Address Phone Email Gender).each do |special_field|
        click_button special_field
        within("#questions") { assert has_content?(special_field) }
      end
      
      within("#questions li", text: "Name") { find("img[alt='Not-required']").click }
      fill_in "Address", with: "I have no home"
      fill_in "Phone", with: "867-5309"
      within("#questions li", text: "Phone") do
        find(".dropdown_icon").click
        click_link "Erase default answer"
        assert has_no_content?("Erase default answer")
      end
      find("label span", text: "Email").click
      within(".inplaceeditor-form") do
        fill_in "value", with: "E-Mail"
        click_button "ok"
      end
      within("#questions li", text: "Gender") do
        find(".dropdown_icon").click
        click_link "Put question above answer"
        assert has_no_content?("Put question above answer")
      end
    end
    
    page1 = @questionnaire.reload.pages.first
    %w(Name Address Phone Email Gender).each_with_index do |field_name, i|
      if field_name == "Email"
        assert_equal "E-Mail", page1.questions[i].caption
      else
        assert_equal field_name, page1.questions[i].caption
      end
      assert_equal field_name.downcase, page1.questions[i].purpose
    end
    
    [0, 2, 3, 4].each { |i| assert page1.questions[i].kind_of?(Questions::TextField) }
    assert page1.questions[1].kind_of?(Questions::BigTextField)
    
    assert page1.questions[0].required?
    assert_equal "I have no home", page1.questions[1].default_answer
    assert page1.questions[2].default_answer.blank?
    [0, 1, 2, 3].each { |i| assert_equal "left", page1.questions[i].layout }
    assert_equal "top", page1.questions[4].layout
  end
  
  test 'creating, renaming and deleting pages' do
    within '#pages' do
      find('.page .caption').click
    end
    
    within_frame 'pageview' do
      find('span', text: "Untitled page").click
      within(".inplaceeditor-form") do
        fill_in "value", with: "Pagina Uno"
        click_button "ok"
      end
    end
    
    within '#pages' do
      assert has_content?("Pagina Uno")

      click_button "Create New Page"
      assert has_content?("Untitled page")
      
      within('.page', text: "Untitled page") do
        page.driver.accept_js_confirms!
        find("img[alt='Delete page']").click
      end
      
      assert has_no_content?("Untitled page")
    end
  end
end