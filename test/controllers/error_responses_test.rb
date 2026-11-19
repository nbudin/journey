require 'test_helper'

# The XML and JSON bodies the editor and API clients get when a save fails.
# (ActiveModel::Errors#to_xml was removed in Rails 7.0; these pin the format it used to produce.)
class ErrorResponsesTest < ActionController::TestCase
  tests QuestionsController

  before do
    @person = FactoryGirl.create(:person)
    sign_in @person
    @page = FactoryGirl.create(:page)
    @questionnaire = @page.questionnaire
    @questionnaire.questionnaire_permissions.create!(person: @person, all_permissions: true)
  end

  def create_invalid(format)
    post :create, params: { questionnaire_id: @questionnaire.id, page_id: @page.id, question: { type: "Questions::TextField", layout: "sideways" }, format: format }
  end

  it "responds to a failed create as XML with an <errors> document" do
    create_invalid(:xml)

    assert_response 500
    assert_equal "application/xml", response.media_type
    doc = REXML::Document.new(response.body)
    assert_equal "errors", doc.root.name
    assert_equal ["Layout is not included in the list"], REXML::XPath.match(doc, "/errors/error").map(&:text)
  end

  it "responds to a failed create as JSON with the errors by attribute" do
    create_invalid(:json)

    assert_response 500
    assert_equal({ "layout" => ["is not included in the list"] }, JSON.parse(response.body))
  end

  describe "errors_xml" do
    it "builds the document ActiveModel::Errors#to_xml used to" do
      question = Questions::TextField.new(layout: "sideways")
      question.valid?
      question.errors.add(:base, "Something else")

      xml = @controller.send(:errors_xml, question)

      assert_equal %(<?xml version="1.0" encoding="UTF-8"?>\n<errors>\n  <error>Layout is not included in the list</error>\n  <error>Something else</error>\n</errors>\n), xml
    end

    it "is an empty document when there are no errors" do
      xml = @controller.send(:errors_xml, Questions::TextField.new)
      assert_equal "errors", REXML::Document.new(xml).root.name
      assert_empty REXML::XPath.match(REXML::Document.new(xml), "/errors/error")
    end
  end
end
