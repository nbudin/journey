# Checks that the TinyMCE editor works against the *precompiled production assets* (public/assets), which neither the
# normal test suite nor render_snapshot_test.rb exercise (they use live compilation).
#
#   bin/rails assets:precompile (RAILS_ENV=production)  # first
#   RAILS_ENV=production SECRET_KEY_BASE=x DATABASE_URL=postgres:///some_migrated_empty_db \
#     bundle exec ruby script/asset_compare/editor_check.rb   # from the repo root
#
# It seeds a person and a questionnaire (use a scratch database!), logs in, opens the pages that have an HTML editor,
# waits for TinyMCE to initialise, types into it, and reports any failed asset requests or JS errors.
ENV["RAILS_ENV"] ||= "production"
abort "use a scratch database; refusing to run outside production-style env" unless ENV["DATABASE_URL"]
require File.expand_path("config/environment", Dir.pwd) # run from the repo root
require "capybara"
require "selenium-webdriver"
require "warden/test/helpers"

include Warden::Test::Helpers
Warden.test_mode!

require "securerandom"
email = "editor-#{SecureRandom.hex(4)}@example.com"
person = Person.create!(username: email, email: email, firstname: "Ed", lastname: "Itor")
questionnaire = Questionnaire.create!(title: "Editor check")
at_exit do
  questionnaire.destroy
  person.destroy
end
questionnaire.questionnaire_permissions.create!(person: person, all_permissions: true)

app = Rack::Builder.new do
  use Rack::Static, urls: ["/assets"], root: Rails.root.join("public").to_s
  run Rails.application
end

Capybara.register_driver :editor_check_chrome do |a|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless=new")
  options.add_argument("--window-size=1280,1024")
  options.add_option("goog:loggingPrefs", { browser: "ALL" })
  Capybara::Selenium::Driver.new(a, browser: :chrome, options: options)
end
Capybara.app = app
Capybara.server = :webrick
session = Capybara::Session.new(:editor_check_chrome, app)
session.driver.browser.manage.window.resize_to(1280, 1024)
login_as person, scope: :person, run_callbacks: false

failures = []
notes = []
pages = {
  "customize (custom_html editor)" => ["/questionnaires/#{questionnaire.id}/customize", nil],
  "show (welcome_text editor)" => ["/questionnaires/#{questionnaire.id}", "Edit welcome text"],
}
pages.each do |name, (path, reveal_button)|
  session.visit path
  session.click_button(reveal_button) if reveal_button
  unless session.has_css?(".mce-tinymce", wait: 15)
    failures << "#{name}: TinyMCE UI never appeared"
    next
  end
  session.has_css?("iframe[id$='_ifr']", wait: 5)
  marker = "typed-by-editor-check"
  session.execute_script("tinymce.activeEditor.focus(); tinymce.activeEditor.execCommand('mceInsertContent', false, '#{marker}')")
  content = session.evaluate_script("tinymce.activeEditor.getContent()")
  failures << "#{name}: inserted text not in editor content (#{content.inspect})" unless content.include?(marker)

  # a real UI interaction: the Bold button should wrap selected text in <strong>
  session.execute_script("tinymce.activeEditor.selection.select(tinymce.activeEditor.getBody().firstChild || tinymce.activeEditor.getBody())")
  session.first(".mce-i-bold").click
  bold = session.evaluate_script("tinymce.activeEditor.getContent()")
  failures << "#{name}: Bold button did not produce <strong> (#{bold.inspect})" unless bold =~ /<(strong|b)>/

  buttons = session.all(".mce-btn", minimum: 1).size
  failures << "#{name}: toolbar looks empty (#{buttons} buttons)" if buttons < 5
  # the theme, skin and plugins are fetched from the non-digested /assets/tinymce/... paths
  loaded = session.evaluate_script("Object.keys(tinymce.PluginManager.lookup).sort().join(',')")
  notes << "#{name}: plugins loaded: #{loaded}"
  puts "ok   #{name}: editor initialised, #{buttons} toolbar buttons, API insert + Bold work"
end

session.driver.browser.logs.get(:browser).each do |entry|
  next unless entry.level == "SEVERE"
  notes << "console: #{entry.message.gsub(/127\.0\.0\.1:\d+/, 'HOST')[0, 200]}"
end
notes.uniq.sort.each { |n| puts "note #{n}" }

puts failures.empty? ? "EDITOR OK" : failures.map { |f| "FAIL #{f}" }.join("\n")
session.driver.quit
exit(failures.empty? ? 0 : 1)
