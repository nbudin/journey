require 'test_helper'

# Creating, changing, ordering and duplicating questions.
# (See questions_controller_test.rb for the basic resource actions.)
class QuestionsFlowTest < ActionController::TestCase
  tests QuestionsController

  before do
    @person = FactoryGirl.create(:person)
    sign_in @person

    @page = FactoryGirl.create(:page)
    @questionnaire = @page.questionnaire
    @permission = @questionnaire.questionnaire_permissions.create!(person: @person, all_permissions: true)

    @first = Questions::TextField.create!(page: @page, caption: "First", position: 1)
    @second = Questions::TextField.create!(page: @page, caption: "Second", position: 2, purpose: "name")
    @third = Questions::TextField.create!(page: @page, caption: "Third", position: 3)
  end

  def params_for(extra = {})
    { questionnaire_id: @questionnaire.id, page_id: @page.id }.merge(extra)
  end

  def ordered_captions
    @page.reload.questions.reorder(:position).map(&:caption)
  end

  describe "create" do
    it "gives new fields a prompt to click on" do
      post :create, params: params_for(question: { type: "Questions::TextField" }, format: :json)
      assert_equal "Click here to type a question.", assigns(:question).caption
    end

    it "gives new decorators the default caption" do
      post :create, params: params_for(question: { type: "Questions::Label" }, format: :json)
      assert_equal "Click here to type.", assigns(:question).caption
    end

    it "keeps a caption that's provided" do
      post :create, params: params_for(question: { type: "Questions::TextField", caption: "Hello?" }, format: :json)
      assert_equal "Hello?", assigns(:question).caption
    end

    it "responds with the location of the new question" do
      post :create, params: params_for(question: { type: "Questions::TextField" }, format: :xml)

      assert_response :created
      assert_match %r{/questions/#{assigns(:question).id}\.xml\z}, response.location
    end

    it "creates every kind of question the editor offers" do
      %w(TextField BigTextField RangeField CheckBoxField DropDownField RadioField Label Divider Heading).each do |type|
        assert_difference("Question.count", 1, type) do
          post :create, params: params_for(question: { type: "Questions::#{type}" }, format: :json)
        end
      end
    end

    it "rejects types it doesn't know about" do
      assert_no_difference("Question.count") do
        error = assert_raises(RuntimeError) { post :create, params: params_for(question: { type: "Kernel" }, format: :json) }
        assert_match(/not a valid question type/, error.message)
      end
    end

    it "requires permission to edit" do
      @permission.update_attributes!(can_edit: false)

      assert_no_difference("Question.count") { post :create, params: params_for(question: { type: "Questions::TextField" }, format: :json) }
      assert_redirected_to root_url
    end
  end

  describe "update" do
    it "changes a question and responds with ok" do
      put :update, params: params_for(id: @first.id, question: { caption: "Renamed", required: "true" }, format: :json)

      assert_response :success
      assert_equal "Renamed", @first.reload.caption
      assert @first.required?
    end

    it "changes the purpose of a question" do
      put :update, params: params_for(id: @first.id, question: { purpose: "email" }, format: :json)

      assert_equal "email", @first.reload.purpose
    end

    it "responds to XML" do
      put :update, params: params_for(id: @first.id, question: { caption: "Renamed" }, format: :xml)
      assert_response :success
    end

    it "reports validation errors as JSON" do
      put :update, params: params_for(id: @first.id, question: { layout: "sideways" }, format: :json)

      assert_response :bad_request
      assert_match(/layout/i, JSON.parse(response.body))
      assert_equal "left", @first.reload.layout
    end

    it "reports validation errors as XML" do
      put :update, params: params_for(id: @first.id, question: { layout: "sideways" }, format: :xml)
      assert_response :bad_request
    end

    it "shows the form again when validation fails for an HTML request" do
      put :update, params: params_for(id: @first.id, question: { layout: "sideways" })
      assert_template "edit"
    end
  end

  describe "destroy" do
    it "removes the question and responds to JSON" do
      delete :destroy, params: params_for(id: @first.id, format: :json)

      assert_response :success
      assert_equal ["Second", "Third"], ordered_captions
    end

    it "removes the question and responds to XML" do
      delete :destroy, params: params_for(id: @second.id, format: :xml)

      assert_response :success
      assert_equal ["First", "Third"], ordered_captions
    end

    it "redirects to the page for HTML" do
      delete :destroy, params: params_for(id: @first.id)
      assert_redirected_to [@questionnaire, @page]
    end
  end

  describe "sort" do
    it "puts the questions in the order given" do
      post :sort, params: params_for(questions: [@third.id, @first.id, @second.id].map(&:to_s))

      assert_response :success
      assert_equal ["Third", "First", "Second"], ordered_captions
    end
  end

  describe "duplicate" do
    it "copies a question right after the original, shifting the ones below it" do
      post :duplicate, params: params_for(id: @first.id)

      assert_response :success
      assert_equal ["First", "First", "Second", "Third"], ordered_captions
      assert_equal [1, 2, 3, 4], @page.reload.questions.reorder(:position).map(&:position)
    end

    it "can make several copies" do
      post :duplicate, params: params_for(id: @second.id, times: 3)
      assert_equal ["First", "Second", "Second", "Second", "Second", "Third"], ordered_captions
    end

    it "doesn't copy the special purpose, which can only belong to one question" do
      post :duplicate, params: params_for(id: @second.id)

      copy = @page.reload.questions.reorder(:position)[2]
      assert_equal "Second", copy.caption
      assert_nil copy.purpose
      assert_equal "name", @second.reload.purpose
    end
  end

  it "renders the option editor" do
    radio = Questions::RadioField.create!(page: @page, caption: "Pick one", position: 4)

    get :edit_options, params: params_for(id: radio.id)

    assert_response :success
    assert assigns(:suppress_custom_html)
    assert assigns(:suppress_custom_css)
  end
end
