require 'test_helper'

# The public-facing flow for answering a questionnaire.
# (See answer_controller_test.rb for the notification email behavior.)
class AnswerFlowTest < ActionController::TestCase
  tests AnswerController

  before do
    @questionnaire = FactoryGirl.create(:questionnaire, is_open: true)
    @page1 = @questionnaire.pages.first
    @page2 = @questionnaire.pages.create!(title: "Second page", position: 2)

    @name = Questions::TextField.create!(page: @page1, caption: "Name", position: 1, required: true, purpose: "name")
    @email = Questions::TextField.create!(page: @page1, caption: "Email", position: 2, purpose: "email")
    @subscribe = Questions::CheckBoxField.create!(page: @page1, caption: "Subscribe?", position: 3)
    @comments = Questions::BigTextField.create!(page: @page2, caption: "Comments", position: 1)
    @questionnaire.reload
  end

  def start_response(person = nil)
    @questionnaire.responses.create!(person: person).tap do |resp|
      session["response_#{@questionnaire.id}"] = resp.id
    end
  end

  describe "prompt" do
    it "is shown to people who aren't logged in" do
      get :prompt, id: @questionnaire.id

      assert_response :success
      assert_empty assigns(:responses)
    end

    it "offers logged in people their unfinished and submitted responses" do
      person = FactoryGirl.create(:person)
      sign_in person
      unfinished = @questionnaire.responses.create!(person: person)
      submitted = @questionnaire.responses.create!(person: person, submitted: true, submitted_at: Time.now)
      @questionnaire.responses.create!(person: FactoryGirl.create(:person))

      get :prompt, id: @questionnaire.id

      assert_equal [unfinished.id, submitted.id].sort, assigns(:responses).map(&:id).sort
    end

    it "only offers what the questionnaire allows" do
      @questionnaire.update_attributes!(allow_finish_later: false, allow_amend_response: false)
      person = FactoryGirl.create(:person)
      sign_in person
      @questionnaire.responses.create!(person: person)
      @questionnaire.responses.create!(person: person, submitted: true, submitted_at: Time.now)

      get :prompt, id: @questionnaire.id

      assert_empty assigns(:responses)
      assert_equal 2, assigns(:all_responses).size
    end
  end

  describe "start" do
    it "creates a response, remembers it in the session, and goes to the first page" do
      assert_difference("Response.count", 1) { get :start, id: @questionnaire.id }

      assert_equal Response.last.id, session["response_#{@questionnaire.id}"]
      assert_nil Response.last.person
      assert_redirected_to action: "index", id: @questionnaire.id
    end

    it "attaches the response to the logged in person" do
      person = FactoryGirl.create(:person)
      sign_in person

      get :start, id: @questionnaire.id
      assert_equal person, Response.last.person
    end

    it "doesn't attach the person if the questionnaire doesn't advertise login" do
      @questionnaire.update_attributes!(advertise_login: false)
      sign_in FactoryGirl.create(:person)

      get :start, id: @questionnaire.id
      assert_nil Response.last.person
    end

    it "sends people back to the prompt when login is required" do
      @questionnaire.update_attributes!(require_login: true)

      assert_no_difference("Response.count") { get :start, id: @questionnaire.id }
      assert_redirected_to action: "prompt", id: @questionnaire.id
    end
  end

  describe "index" do
    it "redirects to the closed page when the questionnaire isn't open" do
      @questionnaire.update_attributes!(is_open: false)

      get :index, id: @questionnaire.id
      assert_redirected_to action: "questionnaire_closed", id: @questionnaire.id.to_s
    end

    it "redirects to the prompt when there's no response in progress" do
      get :index, id: @questionnaire.id
      assert_redirected_to action: "prompt", id: @questionnaire.id
    end

    it "shows the first page by default and other pages on request" do
      start_response

      get :index, id: @questionnaire.id
      assert_response :success
      assert_equal @page1, assigns(:page)

      get :index, id: @questionnaire.id, page: 2
      assert_equal @page2, assigns(:page)
    end

    it "fills in name and email from the logged in person" do
      person = FactoryGirl.create(:person, firstname: "Ada", lastname: "Lovelace", email: "ada@example.com")
      sign_in person
      resp = start_response(person)

      get :index, id: @questionnaire.id

      assert_equal "Ada Lovelace", resp.answer_for_question(@name).value
      assert_equal "ada@example.com", resp.reload.answer_for_question(@email).value
    end

    it "doesn't overwrite answers that were already given" do
      person = FactoryGirl.create(:person)
      sign_in person
      resp = start_response(person)
      resp.answers.create!(question: @name, value: "Someone else")

      get :index, id: @questionnaire.id
      assert_equal "Someone else", resp.reload.answer_for_question(@name).value
    end
  end

  it "explains that a questionnaire is closed" do
    get :questionnaire_closed, id: @questionnaire.id
    assert_response :success
  end

  describe "preview" do
    it "renders the questionnaire without saving a response" do
      assert_no_difference("Response.count") { get :preview, id: @questionnaire.id, page: 2 }

      assert_response :success
      assert_template "index"
      assert_equal @page2, assigns(:page)
    end
  end

  describe "save_answers" do
    before { @resp = start_response }

    def save(answers, commit = "Next >", page = 1)
      post :save_answers, id: @questionnaire.id, current_page: page, commit: commit, question: answers
    end

    it "saves answers and moves to the next page" do
      save({ @name.id.to_s => "Alice", @email.id.to_s => "alice@example.com", @subscribe.id.to_s => "1" })

      assert_redirected_to action: "index", id: @questionnaire.id, page: 2
      @resp.reload
      assert_equal "Alice", @resp.answer_for_question(@name).value
      assert_equal "alice@example.com", @resp.answer_for_question(@email).value
      assert_equal "true", @resp.answer_for_question(@subscribe).value
      assert_equal 2, @resp.saved_page
      refute @resp.submitted
    end

    it "updates existing answers" do
      @resp.answers.create!(question: @name, value: "Old")
      save({ @name.id.to_s => "New" })

      assert_equal ["New"], @resp.reload.answers.map(&:value)
    end

    it "removes answers that have been blanked out" do
      @resp.answers.create!(question: @email, value: "alice@example.com")
      save({ @name.id.to_s => "Alice", @email.id.to_s => "" })

      assert_nil @resp.reload.answer_for_question(@email)
    end

    it "records an unchecked check box as false" do
      @resp.answers.create!(question: @subscribe, value: "1")
      save({ @name.id.to_s => "Alice", @subscribe.id.to_s => "0" })

      assert_equal "false", @resp.reload.answer_for_question(@subscribe).value
    end

    it "moves back a page without insisting on required answers" do
      save({ @comments.id.to_s => "Hello" }, "< Previous", 2)

      assert_redirected_to action: "index", id: @questionnaire.id, page: 1
      assert_equal "Hello", @resp.reload.answer_for_question(@comments).value
    end

    it "shows an error instead of moving on when a required question is unanswered" do
      save({ @name.id.to_s => "" })

      assert_response :success
      assert_template "index"
      assert_equal ["You didn't answer the question \"Name\", which is required."], assigns(:error_messages)
      refute @resp.reload.submitted
    end

    it "submits the response on the last step" do
      save({ @name.id.to_s => "Alice" }, "Submit", 1)

      assert @resp.reload.submitted
      assert_not_nil @resp.submitted_at
      assert_redirected_to action: "save_session", id: @questionnaire.id, current_page: 1
    end

    it "saves for later without validating" do
      save({ @name.id.to_s => "" }, "Save and finish later", 1)

      assert_redirected_to action: "save_session", id: @questionnaire.id, current_page: 1
      refute @resp.reload.submitted
    end
  end

  describe "save_session" do
    before { @resp = start_response }

    it "remembers the page and forgets the response in the session" do
      get :save_session, id: @questionnaire.id, current_page: 2

      assert_response :success
      assert_equal 2, @resp.reload.saved_page.to_i
      assert_nil session["response_#{@questionnaire.id}"]
    end

    # KNOWN BUG: the redirect goes to an "answer" action that has no route, so instead of showing the
    # flash message the user gets an error.  This pins the current behavior; when it's fixed, this should
    # assert the redirect and the flash message instead.
    it "currently fails when the questionnaire doesn't allow finishing later" do
      @questionnaire.update_attributes!(allow_finish_later: false)

      assert_raises(ActionController::UrlGenerationError) do
        get :save_session, id: @questionnaire.id, current_page: 2
      end
    end

    it "doesn't change a submitted response that can't be amended" do
      @questionnaire.update_attributes!(allow_amend_response: false)
      @resp.update_attributes!(submitted: true, submitted_at: Time.now)

      get :save_session, id: @questionnaire.id, current_page: 2
      assert_nil @resp.reload.saved_page
    end
  end

  describe "resume" do
    before do
      @person = FactoryGirl.create(:person)
      sign_in @person
      @resp = @questionnaire.responses.create!(person: @person, saved_page: 2)
    end

    it "puts an unfinished response back in the session and goes to its saved page" do
      get :resume, id: @resp.id

      assert_equal @resp.id, session["response_#{@questionnaire.id}"]
      assert_redirected_to action: "index", id: @questionnaire.id, page: 2
    end

    it "reopens a submitted response for amendment" do
      @resp.update_attributes!(submitted: true, submitted_at: Time.now)

      get :resume, id: @resp.id

      refute @resp.reload.submitted
      assert_nil @resp.submitted_at
      assert_redirected_to action: "index", id: @questionnaire.id, page: 2
    end

    it "won't reopen a submitted response if the questionnaire doesn't allow amending" do
      @questionnaire.update_attributes!(allow_amend_response: false)
      @resp.update_attributes!(submitted: true, submitted_at: Time.now)

      get :resume, id: @resp.id

      assert_match(/does not allow you to amend/, flash[:error_messages].first)
      assert_redirected_to action: "prompt", id: @questionnaire.id
      assert @resp.reload.submitted
    end

    it "won't resume if the questionnaire doesn't allow finishing later" do
      @questionnaire.update_attributes!(allow_finish_later: false)

      get :resume, id: @resp.id
      assert_match(/does not allow you to resume/, flash[:error_messages].first)
    end

    it "won't resume someone else's response" do
      sign_out @person
      sign_in FactoryGirl.create(:person)

      get :resume, id: @resp.id

      assert_match(/does not belong to you/, flash[:error_messages].first)
      assert_nil session["response_#{@questionnaire.id}"]
    end
  end
end
