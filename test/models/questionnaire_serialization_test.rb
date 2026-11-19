require 'test_helper'

# Settings, tags, cloning and XML import/export for Questionnaire
class QuestionnaireSerializationTest < ActiveSupport::TestCase
  def build_questionnaire
    Questionnaire.create!(title: "Rich questionnaire", custom_html: "<b>hello</b>", custom_css: "body { color: red }", welcome_text: "Welcome!").tap do |q|
      page = q.pages.first
      page.update!(title: "Page one")

      Questions::TextField.create!(page: page, caption: "Name", position: 1, required: true, purpose: "name", default_answer: "Anonymous")
      Questions::RangeField.create!(page: page, caption: "Rating", position: 2, min: 1, max: 5, step: 1)
      radio = Questions::RadioField.create!(page: page, caption: "Color", position: 3, default_answer: "b", radio_layout: "horizontal")
      radio.question_options.create!(option: "a", output_value: "Alpha", position: 1)
      radio.question_options.create!(option: "b", position: 2)
      Questions::Label.create!(page: page, caption: "Thanks for answering", position: 4)

      page2 = q.pages.create!(title: "Page two", position: 2)
      Questions::BigTextField.create!(page: page2, caption: "Comments", position: 1)
      q.tags = "survey, test"
    end
  end

  def question_summary(questionnaire, default_answers: true)
    questionnaire.pages.map do |page|
      [page.title, page.questions.map do |question|
        summary = [question.class, question.caption, question.required?]
        summary << question.default_answer if default_answers
        summary
      end]
    end
  end

  describe "tags" do
    before { @questionnaire = Questionnaire.create! }

    it "creates tags from a comma-separated list" do
      @questionnaire.tags = "one, two,three"
      assert_equal %w(one three two), @questionnaire.reload.tag_names.sort
    end

    it "adds and removes tags to match the list" do
      @questionnaire.tags = "one, two"
      @questionnaire.tags = "two, three"
      assert_equal %w(three two), @questionnaire.reload.tag_names.sort
    end

    it "reuses existing tags" do
      @questionnaire.tags = "shared"
      Questionnaire.create!.tags = "shared"
      assert_equal 1, Tag.where(name: "shared").count
    end
  end

  describe "login_policy" do
    { "unadvertised" => [false, false], "prompt" => [true, false], "required" => [true, true] }.each do |policy, (advertise, require_login)|
      it "maps #{policy} to and from advertise_login/require_login" do
        questionnaire = Questionnaire.new
        questionnaire.login_policy = policy

        assert_equal advertise, questionnaire.advertise_login
        assert_equal require_login, questionnaire.require_login
        assert_equal policy, questionnaire.login_policy
      end
    end

    it "ignores unknown policies" do
      questionnaire = Questionnaire.new(advertise_login: true, require_login: true)
      questionnaire.login_policy = "bogus"
      assert_equal "required", questionnaire.login_policy
    end
  end

  describe "publication_mode" do
    { "hidden" => [true, false], "publicly_visible" => [true, true] }.each do |mode, (open, visible)|
      it "maps #{mode} to and from is_open/publicly_visible" do
        questionnaire = Questionnaire.new
        questionnaire.publication_mode = mode

        assert_equal open, questionnaire.is_open
        assert_equal visible, questionnaire.publicly_visible
        assert_equal mode, questionnaire.publication_mode
      end
    end

    it "is unpublished until it has been published, and closed afterwards" do
      questionnaire = Questionnaire.create!
      questionnaire.publication_mode = "unpublished"
      assert_equal "unpublished", questionnaire.publication_mode

      questionnaire.publication_mode = "hidden"
      questionnaire.save!
      questionnaire.publication_mode = "closed"
      questionnaire.save!
      assert_equal "closed", questionnaire.reload.publication_mode
    end

    it "ignores unknown modes" do
      questionnaire = Questionnaire.new
      questionnaire.publication_mode = "publicly_visible"
      questionnaire.publication_mode = "bogus"
      assert_equal "publicly_visible", questionnaire.publication_mode
    end
  end

  describe "deepclone" do
    before do
      @original = build_questionnaire
      2.times do |n|
        response = @original.responses.create!
        response.answers.create!(question: @original.fields.first, value: "Person #{n}")
      end
    end

    it "copies pages, questions, options and tags without responses by default" do
      copy = @original.deepclone
      copy.save!

      refute_equal @original.id, copy.id
      assert_equal question_summary(@original), question_summary(copy.reload)
      assert_equal @original.tag_names.sort, copy.tag_names.sort
      assert_equal 0, copy.responses.count

      copied_radio = copy.questions.find { |q| q.is_a?(Questions::RadioField) }
      assert_equal [["a", "Alpha"], ["b", nil]], copied_radio.question_options.map { |o| [o.option, o.output_value] }
      assert_empty copy.questions.map(&:id) & @original.questions.map(&:id)
    end

    it "copies responses and attaches their answers to the copied questions" do
      copy = @original.deepclone(true)
      copy.save!
      copy.reload

      assert_equal 2, copy.responses.count
      assert_equal ["Person 0", "Person 1"], copy.responses.flat_map { |r| r.answers.map(&:value) }.sort
      copy.responses.each { |r| r.answers.each { |a| assert_includes copy.questions.map(&:id), a.question_id } }
      assert_equal 2, @original.reload.responses.count
    end
  end

  describe "XML export and import" do
    before { @original = build_questionnaire }

    it "exports the questionnaire's structure" do
      xml = REXML::Document.new(@original.to_xml)
      root = xml.root

      assert_equal "questionnaire", root.name
      assert_equal "Rich questionnaire", root.attributes["title"]
      assert_equal %w(survey test), REXML::XPath.match(root, "tags/tag").map { |t| t.attributes["name"] }.sort
      assert_equal "Welcome!", root.elements["welcome_text"].text
      assert_equal ["Page one", "Page two"], REXML::XPath.match(root, "page").map { |p| p.attributes["title"] }
      assert_equal %w(Questions::TextField Questions::RangeField Questions::RadioField Questions::Label),
        REXML::XPath.match(root, "page[1]/question").map { |q| q.attributes["type"] }
      assert_equal "name", root.elements["page[1]/question[1]/purpose"].text
      assert_equal %w(1 5 1), %w(min max step).map { |a| root.elements["page[1]/question[2]/range"].attributes[a] }
      assert_equal "Alpha", REXML::XPath.first(root, "page[1]/question[3]/option").attributes["output_value"]
    end

    it "round-trips through from_xml" do
      imported = Questionnaire.from_xml(@original.to_xml)
      imported.save!
      imported.reload

      refute_equal @original.id, imported.id
      assert_equal @original.title, imported.title
      assert_equal @original.custom_html, imported.custom_html
      assert_equal @original.custom_css, imported.custom_css
      assert_equal @original.welcome_text, imported.welcome_text
      assert_equal %w(survey test), imported.tag_names.sort
      assert_equal question_summary(@original, default_answers: false), question_summary(imported, default_answers: false)
      assert_equal "name", imported.special_field("name").purpose

      range = imported.questions.find { |q| q.is_a?(Questions::RangeField) }
      assert_equal [1, 5, 1], [range.min, range.max, range.step]

      radio = imported.questions.find { |q| q.is_a?(Questions::RadioField) }
      # A missing output value is exported as an empty attribute, so it comes back as "" rather than nil
      assert_equal [["a", "Alpha"], ["b", nil]], radio.question_options.map { |o| [o.option, o.output_value.presence] }
      assert_equal "b", radio.default_answer
      assert_equal "horizontal", radio.radio_layout
    end

    # KNOWN GAP: to_xml writes every question's default answer, but from_xml only reads it back for
    # questions with options (radio buttons, drop-downs).  This pins the current behavior; update it
    # if from_xml is fixed to import default answers for text fields too.
    it "currently drops default answers for questions without options" do
      imported = Questionnaire.from_xml(@original.to_xml)

      assert_equal "Anonymous", @original.questions.first.default_answer
      assert_nil imported.pages.first.questions.first.default_answer
    end

    it "imports questionnaires as closed" do
      refute Questionnaire.from_xml(@original.to_xml).is_open
    end

    it "rejects unknown question types" do
      xml = '<questionnaire title="Bad"><page title="P"><question type="Questions::Nonsense"/></page></questionnaire>'
      error = assert_raises(RuntimeError) { Questionnaire.from_xml(xml) }
      assert_match(/not a valid question type/, error.message)
    end

    it "rejects unexpected elements" do
      error = assert_raises(RuntimeError) { Questionnaire.from_xml('<questionnaire title="Bad"><bogus/></questionnaire>') }
      assert_match(/bogus/, error.message)

      error = assert_raises(RuntimeError) { Questionnaire.from_xml('<questionnaire title="Bad"><page title="P"><bogus/></page></questionnaire>') }
      assert_match(/bogus/, error.message)
    end
  end
end
