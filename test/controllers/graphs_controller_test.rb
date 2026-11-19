require 'test_helper'

class GraphsControllerTest < ActionController::TestCase
  include NonTransactionalDatabase

  PNG_SIGNATURE = "\x89PNG".b

  before do
    @questionnaire = FactoryGirl.create(:questionnaire)
    page = FactoryGirl.create(:page, questionnaire: @questionnaire)
    @range = FactoryGirl.create(:range_field, page: page, caption: "Rate it", position: 1, min: 1, max: 3)
    @color = FactoryGirl.create(:radio_field, page: page, caption: "Color", position: 2)
    @color.question_options.create!(option: "r", output_value: "Red", position: 1)
    @color.question_options.create!(option: "b", output_value: "Blue", position: 2)

    # Three responses: two answer both questions, and one answers only the range
    [["1", "r"], ["1", "b"], ["3", nil]].each do |range_value, color_value|
      response = FactoryGirl.create(:response, questionnaire: @questionnaire)
      response.answers.create!(question: @range, value: range_value)
      response.answers.create!(question: @color, value: color_value) if color_value
    end

    @person = FactoryGirl.create(:person)
    @person.questionnaire_permissions.create(questionnaire: @questionnaire, all_permissions: true)
    sign_in @person
  end

  def assert_png
    assert_response :success
    assert_equal "image/png", response.media_type
    assert_equal PNG_SIGNATURE, response.body.b[0, 4]
  end

  describe "pie" do
    it "renders a PNG" do
      get :pie, params: { questionnaire_id: @questionnaire.id, question_id: @color.id, format: :png }
      assert_png
    end

    it "counts each answer, translating options to output values and counting missing answers" do
      get :pie, params: { questionnaire_id: @questionnaire.id, question_id: @color.id, format: :png }
      assert_equal({ "Red" => 1, "Blue" => 1, "No answer" => 1 }, assigns(:answercounts))
    end

    it "leaves out missing answers when skip_no_answer is set" do
      get :pie, params: { questionnaire_id: @questionnaire.id, question_id: @color.id, skip_no_answer: "true", format: :png }
      assert_equal({ "Red" => 1, "Blue" => 1 }, assigns(:answercounts))
    end

    it "accepts a custom geometry" do
      get :pie, params: { questionnaire_id: @questionnaire.id, question_id: @color.id, geom: "320x200", format: :png }
      assert_png
      assert_equal "320x200", assigns(:geom)
    end

    it "is not available to people who can't view answers" do
      sign_out @person
      sign_in FactoryGirl.create(:person)

      get :pie, params: { questionnaire_id: @questionnaire.id, question_id: @color.id, format: :png }
      assert_redirected_to root_url
      assert_not_equal "image/png", response.media_type.to_s
    end
  end

  describe "line" do
    it "renders a PNG" do
      get :line, params: { questionnaire_id: @questionnaire.id, question_ids: [@range.id], format: :png }
      assert_png
    end

    it "builds a series of counts for each value in the range" do
      get :line, params: { questionnaire_id: @questionnaire.id, question_ids: [@range.id], skip_no_answer: "true", format: :png }

      assert_equal [@range], assigns(:series).keys
      assert_equal [2, 0, 1], assigns(:series)[@range]
    end

    it "is not available to people who can't view answers" do
      sign_out @person
      sign_in FactoryGirl.create(:person)

      get :line, params: { questionnaire_id: @questionnaire.id, question_ids: [@range.id], format: :png }
      assert_redirected_to root_url
      assert_not_equal "image/png", response.media_type.to_s
    end
  end
end
