require 'test_helper'

class QuestionnairesImportExportTest < ActionController::TestCase
  tests QuestionnairesController

  before do
    @person = FactoryGirl.create(:person)
    sign_in @person

    @questionnaire = FactoryGirl.create(:questionnaire, title: "Original")
    page = @questionnaire.pages.first
    Questions::TextField.create!(page: page, caption: "Name", position: 1, purpose: "name")
    @permission = @questionnaire.questionnaire_permissions.create!(person: @person, can_edit: true, can_view_answers: true)
  end

  def uploaded_file(content)
    file = Tempfile.new(["import", ".xml"])
    file.write(content)
    file.close
    (@tempfiles ||= []) << file
    Rack::Test::UploadedFile.new(file.path, "text/xml")
  end

  teardown { (@tempfiles || []).each(&:unlink) }

  describe "exporting" do
    it "exports XML for people who can edit" do
      get :show, params: { id: @questionnaire.id, format: :xml }

      assert_response :success
      assert_match(/attachment; filename="Original.xml"/, response.headers["Content-Disposition"])
      assert_equal "Original", REXML::Document.new(response.body).root.attributes["title"]
    end

    it "refuses to export XML to people who can only view answers" do
      @permission.update!(can_edit: false)
      get :show, params: { id: @questionnaire.id, format: :xml }
      assert_response :forbidden
    end

    it "exports JSON without the RSS secret" do
      get :show, params: { id: @questionnaire.id, format: :json }

      assert_response :success
      json = JSON.parse(response.body)
      assert_equal "Original", json["title"]
      refute json.key?("rss_secret")
    end

    it "limits the JSON to the requested attributes" do
      get :show, params: { id: @questionnaire.id, attributes: ["title"], format: :json }
      assert_equal ["title"], JSON.parse(response.body).keys
    end

    it "refuses to export JSON to people who can't edit" do
      @permission.update!(can_edit: false)
      get :show, params: { id: @questionnaire.id, format: :json }
      assert_response :forbidden
    end
  end

  describe "importing" do
    it "creates a questionnaire from an exported XML file" do
      xml = @questionnaire.to_xml

      assert_difference("Questionnaire.count", 1) do
        post :create, params: { file: uploaded_file(xml) }
      end

      imported = assigns(:questionnaire)
      assert_redirected_to questionnaire_url(imported)
      assert_equal ["Name"], imported.questions.map(&:caption)
      assert imported.questionnaire_permissions.find_by(person_id: @person.id).can_destroy
    end

    it "explains what went wrong when the file isn't valid" do
      assert_no_difference("Questionnaire.count") do
        post :create, params: { file: uploaded_file("<questionnaire title='x'><bogus/></questionnaire>") }
      end

      assert_redirected_to action: "new"
      assert_match(/error parsing the XML/, flash[:error_messages].first)
      assert_match(/bogus/, flash[:error_messages].last)
    end

    it "asks for a file when Import is clicked without one" do
      assert_no_difference("Questionnaire.count") { post :create, params: { commit: "Import" } }

      assert_redirected_to action: "new"
      assert_equal ["Please specify a file to import."], flash[:error_messages]
    end
  end

  describe "cloning" do
    before do
      response = @questionnaire.responses.create!
      response.answers.create!(question: @questionnaire.fields.first, value: "Alice")
    end

    it "makes a closed copy owned by the current person, without responses by default" do
      assert_difference("Questionnaire.count", 1) { post :create, params: { clone_questionnaire_id: @questionnaire.id } }

      copy = assigns(:questionnaire)
      assert_equal "Copy of Original", copy.title
      refute copy.is_open
      assert_equal 0, copy.responses.count
      assert_equal ["Name"], copy.questions.map(&:caption)
      assert copy.questionnaire_permissions.find_by(person_id: @person.id).can_destroy
    end

    it "copies responses when asked" do
      post :create, params: { clone_questionnaire_id: @questionnaire.id, clone_responses: "true" }
      assert_equal 1, assigns(:questionnaire).responses.count
    end
  end

  describe "creating" do
    it "falls back to a default title" do
      post :create, params: { questionnaire: { welcome_text: "Hi" } }
      assert_equal "Untitled questionnaire", assigns(:questionnaire).title
    end
  end

  describe "special field purposes" do
    it "lists the unused purposes as XML" do
      get :available_special_field_purposes, params: { id: @questionnaire.id, format: :xml }

      purposes = REXML::XPath.match(REXML::Document.new(response.body), "//purpose").map(&:text)
      refute_includes purposes, "name"
      assert_includes purposes, "email"
    end

    it "lists the unused purposes as JSON" do
      get :available_special_field_purposes, params: { id: @questionnaire.id, format: :json }

      purposes = JSON.parse(response.body)
      refute_includes purposes, "name"
      assert_includes purposes, "email"
    end
  end

  it "renders the page list" do
    get :pagelist, params: { id: @questionnaire.id }
    assert_response :success
  end

  it "doesn't let people without permission destroy a questionnaire" do
    assert_no_difference("Questionnaire.count") { delete :destroy, params: { id: @questionnaire.id } }
    assert_redirected_to root_url
  end
end
