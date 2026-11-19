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
    get :index, params: { questionnaire_id: @questionnaire.id, format: :csv }

    assert_response :success
    assert_match %r{text/csv}, response.media_type.to_s
    assert_equal [["id", "Submitted", "Notes", "Name"], [@response_id.to_s, nil, nil, "Alice"]], CSV.parse(response.body)
  end

  it "downloads rotated CSV when asked to" do
    get :index, params: { questionnaire_id: @questionnaire.id, rotate: "true", format: :csv }

    assert_response :success
    assert_equal [["id", @response_id.to_s], ["Submitted", nil], ["Notes", nil], ["Name", "Alice"]], CSV.parse(response.body)
  end

  it "makes a safe filename from the questionnaire title" do
    get :index, params: { questionnaire_id: @questionnaire.id, format: :csv }

    # Rails 6 percent-encodes the filename (RFC 6266); browsers decode the filename* parameter back to
    # "Survey- the (sequel)--.csv"
    header = response.headers["Content-Disposition"]
    assert_match(/\Aattachment;/, header)
    assert_includes header, "filename*=UTF-8''Survey-%20the%20%28sequel%29--.csv"
    assert_equal "Survey- the (sequel)--.csv", URI.decode_www_form_component(header[/filename\*=UTF-8''([^;]+)/, 1].gsub("+", "%2B"))
  end

  it "requires permission to view answers" do
    sign_out @person
    sign_in FactoryGirl.create(:person)

    get :index, params: { questionnaire_id: @questionnaire.id, format: :csv }
    assert_redirected_to root_url
  end
end
