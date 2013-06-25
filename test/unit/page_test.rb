require 'test_helper'

class PageTest < ActiveSupport::TestCase
  describe "A new page" do
    before do
      @page = Page.create
    end
    
    it "should be called 'untitled'" do
      assert_match /untitled/i, @page.title
    end
  end
end
