require 'test_helper'

class ResponsesCsvExportTest < ActionController::TestCase
  tests ResponsesController
  include NonTransactionalDatabase

  before do
    @questionnaire = FactoryGirl.create(:questionnaire, title: "Survey: the (sequel)/?")
    page = FactoryGirl.create(:page, questionnaire: @questionnaire)
    name = FactoryGirl.create(:text_field, page: page, caption: "Name", position: 1)
    response = FactoryGirl.create(:response, questionnaire: @questionnaire)
    response.answers.create!(question: name, value: "Alice")
    @response_id = response.id

    @person = FactoryGirl.create(:person)
    @person.questionnaire_permissions.create(questionnaire: @questionnaire, all_permissions: true)
    sign_in @person
  end

  it "downloads responses as CSV" do
    get :index, questionnaire_id: @questionnaire.id, format: :csv

    assert_response :success
    assert_match %r{text/csv}, response.content_type.to_s
    assert_equal [["id", "Submitted", "Notes", "Name"], [@response_id.to_s, nil, nil, "Alice"]], CSV.parse(response.body)
  end

  it "downloads rotated CSV when asked to" do
    get :index, questionnaire_id: @questionnaire.id, rotate: "true", format: :csv

    assert_response :success
    assert_equal [["id", @response_id.to_s], ["Submitted", nil], ["Notes", nil], ["Name", "Alice"]], CSV.parse(response.body)
  end

  it "makes a safe filename from the questionnaire title" do
    get :index, questionnaire_id: @questionnaire.id, format: :csv

    assert_match(/filename="?Survey- the \(sequel\)--\.csv"?/, response.headers["Content-Disposition"])
  end

  it "requires permission to view answers" do
    sign_out @person
    sign_in FactoryGirl.create(:person)

    get :index, questionnaire_id: @questionnaire.id, format: :csv
    assert_redirected_to root_url
  end
end
