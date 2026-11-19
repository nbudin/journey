require 'test_helper'

# Viewing, editing and subscribing to the responses to a questionnaire.
# (See responses_controller_test.rb for the basic resource actions.)
class ResponsesFlowTest < ActionController::TestCase
  tests ResponsesController

  before do
    @questionnaire = FactoryGirl.create(:questionnaire, title: "Survey")
    page = @questionnaire.pages.first
    @name = Questions::TextField.create!(page: page, caption: "Name", position: 1, purpose: "name")
    @email = Questions::TextField.create!(page: page, caption: "Email", position: 2, purpose: "email")
    @rating = Questions::RangeField.create!(page: page, caption: "Rating", position: 3, min: 1, max: 5)
    @story = Questions::BigTextField.create!(page: page, caption: "Story", position: 4)
    @questionnaire.reload

    @person = FactoryGirl.create(:person)
    @permission = @questionnaire.questionnaire_permissions.create!(person: @person, all_permissions: true)
    sign_in @person

    @alice = create_response(@name => "Alice", @email => "alice@example.com", @rating => "4")
    @bob = create_response(@name => "Bob", @email => "bob@example.com", @rating => "2")
  end

  def create_response(answers)
    @questionnaire.responses.create!(submitted: true, submitted_at: Time.now).tap do |resp|
      answers.each { |question, value| resp.answers.create!(question: question, value: value) }
    end
  end

  describe "index" do
    it "lists responses that have answers, most recent first" do
      @questionnaire.responses.create!  # no answers, so not a valid response

      get :index, questionnaire_id: @questionnaire.id

      assert_response :success
      assert_equal [@bob.id, @alice.id], assigns(:responses).map(&:id)
    end

    it "shows title, submitted, notes, the other special fields and id by default" do
      get :index, questionnaire_id: @questionnaire.id
      assert_equal ["title", "submitted_at", "notes", @email, "id"], assigns(:columns)
    end

    it "lets people choose which columns to show" do
      get :index, questionnaire_id: @questionnaire.id, column_1: "id", column_2: "question_#{@rating.id}", column_3: "notes"

      assert_equal ["id", @rating, "notes", "submitted_at", "title"].first(3), assigns(:columns).first(3)
      assert_equal 5, assigns(:columns).size
    end

    it "ignores columns it doesn't recognize or that belong to other questionnaires" do
      other = FactoryGirl.create(:questionnaire)
      foreign = Questions::TextField.create!(page: other.pages.first, caption: "Foreign", position: 1)

      get :index, questionnaire_id: @questionnaire.id, column_1: "bogus", column_2: "question_#{foreign.id}"

      refute_includes assigns(:columns), foreign
      assert_equal "title", assigns(:columns).first
    end

    it "requires permission to view answers" do
      # Either can_view_answers or can_edit_answers is enough to see responses
      @permission.update_attributes!(can_view_answers: false, can_edit_answers: false)

      get :index, questionnaire_id: @questionnaire.id
      assert_redirected_to root_url
    end

    describe "as an RSS feed" do
      it "works for a logged in person when the secret matches" do
        get :index, questionnaire_id: @questionnaire.id, format: :rss, secret: @questionnaire.rss_secret

        assert_response :success
        assert_match %r{<rss}, response.body
      end

      it "rejects the wrong secret" do
        assert_raises(UncaughtThrowError) do
          get :index, questionnaire_id: @questionnaire.id, format: :rss, secret: "wrong"
        end
      end

      # KNOWN BUG: the controller exempts RSS from the view-answers check so that feed readers can use the
      # secret, but load_and_authorize_resource runs first and sends logged out requests to the home page.
      # This pins the current behavior; when it's fixed, this should expect the feed instead.
      it "currently redirects logged out requests even when the secret matches" do
        sign_out @person

        get :index, questionnaire_id: @questionnaire.id, format: :rss, secret: @questionnaire.rss_secret
        assert_response :redirect
      end
    end
  end

  describe "show" do
    it "returns JSON with the rendered response and its title" do
      get :show, questionnaire_id: @questionnaire.id, id: @alice.id, format: :json

      json = JSON.parse(response.body)
      assert_equal "Alice", json["title"]
      assert_includes json["content"], "alice@example.com"
    end
  end

  describe "edit" do
    it "returns JSON with an edit form" do
      get :edit, questionnaire_id: @questionnaire.id, id: @alice.id, format: :json

      json = JSON.parse(response.body)
      assert_equal "Editing Alice", json["title"]
      assert_includes json["content"], "<form"
    end
  end

  describe "update" do
    it "saves notes and changes answers" do
      put :update, questionnaire_id: @questionnaire.id, id: @alice.id,
        response: { notes: "Followed up" },
        answer: { @name.id.to_s => "Alicia", @story.id.to_s => "A long tale" }

      assert_redirected_to [@questionnaire, @alice]
      @alice.reload
      assert_equal "Followed up", @alice.notes
      assert_equal "Alicia", @alice.answer_for_question(@name).value
      assert_equal "A long tale", @alice.answer_for_question(@story).value
    end

    it "removes answers that are no longer given" do
      put :update, questionnaire_id: @questionnaire.id, id: @alice.id, answer: { @name.id.to_s => "Alice", @email.id.to_s => "" }

      @alice.reload
      assert_equal "Alice", @alice.answer_for_question(@name).value
      assert_nil @alice.answer_for_question(@email)
    end

    it "only lets people who can edit answers do it" do
      @permission.update_attributes!(can_edit_answers: false)

      put :update, questionnaire_id: @questionnaire.id, id: @alice.id, response: { notes: "Nope" }

      assert_redirected_to root_url
      assert_nil @alice.reload.notes
    end
  end

  describe "create and destroy as XML" do
    # KNOWN BUG: the record is saved, but building the XML response's location calls a response_url helper
    # that doesn't exist (the route is nested under the questionnaire), so the request fails.  This pins the
    # current behavior; when it's fixed, this should expect a 201.
    it "currently saves the response and then fails to build its location" do
      assert_difference("Response.count", 1) do
        assert_raises(NoMethodError) do
          post :create, questionnaire_id: @questionnaire.id, response: { notes: "Hi" }, format: :xml
        end
      end
    end

    it "destroys a response" do
      assert_difference("Response.count", -1) { delete :destroy, questionnaire_id: @questionnaire.id, id: @bob.id, format: :xml }
      assert_response :success
    end
  end

  it "renders the printable view of valid responses" do
    get :print, questionnaire_id: @questionnaire.id

    assert_response :success
    assert_equal [@bob.id, @alice.id], assigns(:responses).map(&:id)
  end

  describe "aggregate" do
    it "splits the questions that can be graphed by whether they're numeric, leaving out free text" do
      color = Questions::RadioField.create!(page: @questionnaire.pages.first, caption: "Color", position: 5)
      color.question_options.create!(option: "Red", position: 1)

      get :aggregate, questionnaire_id: @questionnaire.id

      assert_response :success
      assert_equal [@rating], assigns(:numeric_fields)
      assert_equal [color], assigns(:nonnumeric_fields)
      refute_includes assigns(:fields), @name
      refute_includes assigns(:fields), @story
    end
  end

  it "renders the export page" do
    get :export, questionnaire_id: @questionnaire.id
    assert_response :success
  end

  describe "subscriptions" do
    it "shows the subscription form" do
      get :subscribe, questionnaire_id: @questionnaire.id
      assert_response :success
    end

    it "turns notifications on and off for the current person" do
      put :update_subscription, questionnaire_id: @questionnaire.id, email_notification: { notify_on_response_submit: "0" }
      notification = @questionnaire.email_notifications.find_by(person_id: @person.id)
      refute notification.notify_on_response_submit
      assert_redirected_to action: "subscribe"

      put :update_subscription, questionnaire_id: @questionnaire.id, email_notification: { notify_on_response_submit: "1" }
      assert notification.reload.notify_on_response_submit
      assert_equal 1, @questionnaire.email_notifications.where(person_id: @person.id).count
    end
  end
end
