require 'test_helper'

class PageTest < ActiveSupport::TestCase
  describe "A new page" do
    before do
      @questionnaire = FactoryGirl.create(:questionnaire)
      @page = @questionnaire.pages.create
    end
    
    it "should be called 'untitled'" do
      assert_match /untitled/i, @page.title
    end
  end
  
  test "A page in a questionnaire should calculate its number correctly" do
    questionnaire = FactoryGirl.create(:questionnaire)
    questionnaire.pages.destroy_all
    
    pages = [1, 5, 60, 61, 800].map do |position|
      questionnaire.pages.create(:position => position)
    end
    
    pages.each_with_index do |page, index|
      assert_equal index + 1, page.reload.number
    end
  end
  
  describe "A page with a bunch of questions" do
    before do
      @questionnaire = FactoryGirl.create(:comprehensive_questionnaire)
      @page = @questionnaire.pages.first
      assert_equal 9, @page.questions.size
    end
    
    it "should distinguish decorators from fields" do
      assert_equal 6, @page.fields.size
      assert_equal 3, @page.decorators.size
    end
  end
end
