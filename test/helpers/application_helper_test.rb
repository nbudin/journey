require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  describe "image_tag" do
    it "derives alt text from the file name" do
      assert_match(/alt="Not required"/, image_tag("not-required.png"))
      assert_match(/alt="Clear field"/, image_tag("clear_field.png"))
    end

    it "ignores directories, extensions and digests" do
      assert_match(/alt="Edit field"/, image_tag("jipe/edit-field.png"))
      assert_match(/alt="Edit field"/, image_tag("edit-field-#{'a1' * 16}.png"))
    end

    it "lets an explicit alt win, including no alt at all" do
      assert_match(/alt="Delete field"/, image_tag("delete.png", alt: "Delete field"))
      refute_match(/alt=/, image_tag("delete.png", alt: nil))
    end

    it "keeps other options" do
      html = image_tag("delete.png", class: "image_button", id: "thing")
      assert_match(/class="image_button"/, html)
      assert_match(/id="thing"/, html)
    end

    it "doesn't invent alt text for data URIs" do
      refute_match(/alt=/, image_tag("data:image/gif;base64,R0lGODlhAQABAAAAACw="))
    end
  end
end
