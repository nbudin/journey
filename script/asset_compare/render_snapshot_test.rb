# Dumps computed styles, element geometry and screenshots for a fixed set of pages, so the output of two
# different asset pipelines can be compared.  Run from the journey repo:
#   SNAPSHOT_OUT=/some/dir bin/rails test /path/to/render_snapshot_test.rb
require "test_helper"
require "json"
require "fileutils"

class RenderSnapshotTest < ActionDispatch::IntegrationTest
  DUMP_JS = <<~JS
    (function () {
      var styles = {}, styleIds = {}, els = {}, rects = {};
      function nthPath(el) {
        var parts = [];
        while (el && el.nodeType === 1) {
          var i = 1, sib = el;
          while ((sib = sib.previousElementSibling)) i++;
          parts.unshift(el.tagName.toLowerCase() + (el.id ? "#" + el.id : "") + ":" + i);
          el = el.parentElement;
        }
        return parts.join(">");
      }
      function walk(doc, prefix) {
        var all = doc.querySelectorAll("*");
        var win = doc.defaultView;
        for (var n = 0; n < all.length; n++) {
          var el = all[n];
          if (/^(script|style|link|meta|title|head|noscript)$/i.test(el.tagName) && el.tagName.toLowerCase() !== "style") continue;
          var key = prefix + nthPath(el);
          var cs = win.getComputedStyle(el), o = {};
          for (var p = 0; p < cs.length; p++) o[cs[p]] = cs.getPropertyValue(cs[p]);
          var s = JSON.stringify(o);
          if (!(s in styleIds)) { styleIds[s] = "s" + Object.keys(styleIds).length; styles[styleIds[s]] = o; }
          els[key] = styleIds[s];
          var r = el.getBoundingClientRect();
          rects[key] = [Math.round(r.x), Math.round(r.y), Math.round(r.width), Math.round(r.height)];
          if (el.tagName === "IFRAME") {
            try { if (el.contentDocument) walk(el.contentDocument, key + "|iframe|"); } catch (e) {}
          }
        }
      }
      walk(document, "");
      return JSON.stringify({ styles: styles, els: els, rects: rects });
    })();
  JS

  before do
    @out = ENV.fetch("SNAPSHOT_OUT")
    # Same database ids on every run, so element ids and hrefs are comparable between runs
    conn = ActiveRecord::Base.connection
    tables = (conn.tables - %w[schema_migrations ar_internal_metadata]).map { |t| conn.quote_table_name(t) }
    conn.execute("TRUNCATE #{tables.join(', ')} RESTART IDENTITY CASCADE")
    FileUtils.mkdir_p(@out)

    @admin = FactoryGirl.create(:person, firstname: "Ada", lastname: "Admin", email: "ada@example.com", username: "ada@example.com")
    @questionnaire = FactoryGirl.create(:comprehensive_questionnaire, title: "Snapshot survey")
    @questionnaire.questionnaire_permissions.create(person: @admin, all_permissions: true)
    @questionnaire.update!(is_open: true, advertise_login: false, require_login: false)

    fixed = { "Big text field" => "Some long free text answer.", "Text field" => "Short answer", "Range field" => "3",
              "Check box field" => "true", "Radio field" => "Option 2", "Drop down field" => "Option 3" }
    2.times do |n|
      resp = Response.create!(questionnaire: @questionnaire, submitted: true, submitted_at: Time.utc(2020, 1, 1 + n), person: @admin)
      @questionnaire.fields.each do |field|
        value = fixed[field.caption] || "Answer #{n}"
        Answer.create!(response: resp, question: field, value: value)
      end
    end
    @snap_response = Response.first
    @page = @questionnaire.pages.first

    Capybara.current_driver = Capybara.javascript_driver
    login_as @admin, scope: :person, run_callbacks: false
    page.driver.browser.manage.window.resize_to(1280, 1024)
  end

  def snapshot(name, path)
    visit path
    sleep 1.5 # let Prototype ajax-populated sections and iframes load
    data = page.evaluate_script(DUMP_JS)
    File.write(File.join(@out, "#{name}.json"), data)
    page.driver.save_screenshot(File.join(@out, "#{name}.png"))
    assert JSON.parse(data)["els"].size > 5, "#{name} rendered almost nothing (#{page.current_path})"
  end

  test "snapshot pages" do
    q = @questionnaire
    pages = {
      "root" => root_path,
      "dashboard" => dashboard_path,
      "welcome" => welcome_path,
      "questionnaires_index" => questionnaires_path,
      "questionnaire_show" => questionnaire_path(q),
      "questionnaire_edit" => edit_questionnaire_path(q),
      "page_view" => questionnaire_page_path(q, @page),
      "pagelist" => pagelist_questionnaire_path(q),
      "customize" => customize_questionnaire_path(q),
      "export" => export_questionnaire_path(q),
      "share" => share_questionnaire_path(q),
      "print" => print_questionnaire_path(q),
      "publish" => questionnaire_publish_path(q),
      "publish_settings" => settings_questionnaire_publish_path(q),
      "answer_start" => questionnaire_answer_path(q),
      "answer_prompt" => questionnaire_answer_prompt_path(q),
      "answer_start_page" => questionnaire_answer_start_path(q),
      "answer_preview" => questionnaire_answer_preview_path(q),
      "responses" => questionnaire_responses_path(q),
      "response_show" => questionnaire_response_path(q, @snap_response),
      "response_aggregate" => aggregate_questionnaire_responses_path(q),
      "responses_print" => print_questionnaire_responses_path(q),
      "graphs" => response_graphs_path(q),
    }
    pages.each { |name, path| snapshot(name, path) }
    File.write(File.join(@out, "_pages.json"), JSON.pretty_generate(pages))
  end
end
