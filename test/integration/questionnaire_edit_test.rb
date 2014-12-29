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
      
      within("#questions li", text: "Name") { find("img[alt='Not required']").click }
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
        accept_confirm "Do you really want to delete the page \"Untitled page\"?" do
          find("img[alt='Delete page']").click
        end        
      end
      
      assert has_no_content?("Untitled page")
    end
  end
  
  test 'creating other types of questions' do
    skip('this test has never worked right, and probably never will in the Prototype.js version of the app')
    
    within '#pages' do
      find('.page .caption').click
    end
    
    within_frame 'pageview' do
      within('#toolbox') { click_link "Questions" }
      
      ["Freeform", "Big freeform", "Numeric range", "Check box", "Drop-down menu", "Radio buttons"].each do |field_type|
        click_button field_type
        find("label span", text: "Click here to type a question.").click
        within(".inplaceeditor-form") do
          fill_in "value", with: field_type
          click_button "ok"
        end
        within("#questions") { assert has_content?(field_type) }
      end
      
      within("#questions li", text: "Numeric range") do
        within ".questionbody" do
          all("span", text: "0").first.click
          within(".inplaceeditor-form") do
            fill_in "value", with: "-3"
            click_button "ok"
          end
          
          assert has_content?("-3")
          
          find("span", text: "0").click
          within(".inplaceeditor-form") do
            fill_in "value", with: "5"
            click_button "ok"
          end
          
          assert has_content?("5")
          assert has_content?("[")
          assert has_content?("]")
        end
      end
      
      # TODO: seems like Capybara-webkit can't handle iframes in iframes, which we'd need to edit options.
    end
    
    page1 = @questionnaire.reload.pages.first
    [Questions::TextField, Questions::BigTextField, Questions::RangeField, Questions::CheckBoxField, Questions::DropDownField, Questions::RadioField].each_with_index do |klass, i|
      assert page1.questions[i].is_a? klass
    end
    
    assert_equal -3, page1.questions[2].min
    assert_equal 5, page1.questions[2].max
  end
end