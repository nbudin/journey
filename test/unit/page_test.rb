require File.dirname(__FILE__) + '/../test_helper'

class PageTest < ActiveSupport::TestCase
  context "A new page" do
    setup do
      @page = Page.create
    end
    
    should "be called 'untitled'" do
      assert_match /untitled/i, @page.title
    end
  end
end
