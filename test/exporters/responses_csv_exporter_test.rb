require 'test_helper'

class ResponsesCsvExporterTest < ActiveSupport::TestCase
  include NonTransactionalDatabase

  before do
    @questionnaire = FactoryGirl.create(:questionnaire, title: "Export test")
    page = FactoryGirl.create(:page, questionnaire: @questionnaire)

    # Positions are set explicitly because questions created without one all get position 0,
    # which would leave the order of the export columns up to the database.
    @name = FactoryGirl.create(:text_field, page: page, caption: "Name", position: 1)
    @color = FactoryGirl.create(:radio_field, page: page, caption: "Color", position: 2)
    @color.question_options.create!(option: "r", output_value: "Red", position: 1)
    @color.question_options.create!(option: "b", position: 2)

    @alice = create_response(@name => "Alice", @color => "r", notes: "First")
    @bob = create_response(@name => "Bob", @color => "b")
    @color_only = create_response(@color => "r")
    @empty = FactoryGirl.create(:response, questionnaire: @questionnaire)

    other = FactoryGirl.create(:questionnaire)
    other_page = FactoryGirl.create(:page, questionnaire: other)
    other_question = FactoryGirl.create(:text_field, page: other_page, position: 1)
    other_response = FactoryGirl.create(:response, questionnaire: other)
    other_response.answers.create!(question: other_question, value: "Should never be exported")
  end

  def create_response(answers_by_question)
    notes = answers_by_question.delete(:notes)
    FactoryGirl.create(:response, questionnaire: @questionnaire, notes: notes).tap do |response|
      answers_by_question.each { |question, value| response.answers.create!(question: question, value: value) }
    end
  end

  def export_rows(rotate)
    rows = []
    ResponsesCsvExporter.new(@questionnaire.reload, rotate).each_row { |row| rows << row }
    rows
  end

  describe "one row per response" do
    it "has a header row with the question captions" do
      assert_equal ["id", "Submitted", "Notes", "Name", "Color"], export_rows(false).first
    end

    it "lists responses newest first, using output values where options define them" do
      rows = export_rows(false)

      assert_equal [@color_only.id, @bob.id, @alice.id], rows.drop(1).map(&:first)
      assert_equal [@alice.id, nil, "First", "Alice", "Red"], rows.last
      assert_equal [@bob.id, nil, nil, "Bob", "b"], rows[2]
    end

    it "leaves blank cells for unanswered questions" do
      row = export_rows(false).find { |r| r.first == @color_only.id }
      assert_equal [@color_only.id, nil, nil, "", "Red"], row
    end

    it "leaves out responses with no answers and responses to other questionnaires" do
      rows = export_rows(false)
      assert_equal 4, rows.size
      refute_includes rows.flatten, "Should never be exported"
      refute_includes rows.map(&:first), @empty.id
    end
  end

  describe "rotated, with one row per question" do
    it "has id, submitted and notes rows, with a column per response in id order" do
      rows = export_rows(true)

      assert_equal ["id", @alice.id, @bob.id, @color_only.id], rows[0]
      assert_equal ["Submitted", nil, nil, nil], rows[1]
      assert_equal ["Notes", "First", nil, nil], rows[2]
    end

    it "has a row per answered question, using output values where options define them" do
      rows = export_rows(true)

      assert_equal 5, rows.size
      assert_equal ["Name", "Alice", "Bob"], rows[3]
      assert_equal ["Color", "Red", "b", "Red"], rows[4]
    end
  end

  it "yields nothing but headers for a questionnaire without responses" do
    empty = FactoryGirl.create(:questionnaire)
    rows = []
    ResponsesCsvExporter.new(empty, false).each_row { |row| rows << row }
    assert_equal [["id", "Submitted", "Notes"]], rows
  end
end
