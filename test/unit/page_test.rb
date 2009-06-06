require File.dirname(__FILE__) + '/../test_helper'

class PageTest < ActiveSupport::TestCase
  should_belong_to :questionnaire
  should_have_many :questions
  should_have_many :fields
  should_have_many :decorators
  
  context "A new page" do
    setup do
      @page = Page.create
    end
    
    should "be called 'untitled'" do
      assert_match /untitled/i, @page.title
    end
  end
end
