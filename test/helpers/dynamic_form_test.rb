require 'test_helper'

# error_messages_for / error_message_on come from the vendored dynamic_form gem
class DynamicFormHelperTest < ActionView::TestCase
  before do
    @questionnaire = Questionnaire.new
    @questionnaire.errors.add(:title, "can't be blank")
    @questionnaire.errors.add(:base, "Something else is wrong")
  end

  it "lists an object's error messages" do
    view.assign(questionnaire: @questionnaire)
    html = view.error_messages_for(:questionnaire)

    assert_includes html, 'id="errorExplanation"'
    assert_includes html, "2 errors prohibited this questionnaire from being saved"
    assert_includes html, "Title can&#39;t be blank"
    assert_includes html, "Something else is wrong"
  end

  it "renders nothing for an object without errors" do
    view.assign(questionnaire: Questionnaire.new)
    assert_equal "", view.error_messages_for(:questionnaire)
  end

  it "formats full messages the standard Rails way" do
    assert_equal ["Title can't be blank", "Something else is wrong"], @questionnaire.errors.full_messages
  end
end
