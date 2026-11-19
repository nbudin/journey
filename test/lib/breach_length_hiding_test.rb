require 'test_helper'
require 'rack/mock'

class BreachLengthHidingTest < ActiveSupport::TestCase
  def call(content_type: "text/html; charset=utf-8", https: true, body: "<html><body>Hello</body></html>")
    inner = ->(_env) { [200, { "Content-Type" => content_type }, [body]] }
    env = Rack::MockRequest.env_for("/", https ? { "HTTPS" => "on" } : {})
    status, headers, response_body = BreachLengthHiding.new(inner).call(env)
    [status, headers, response_body.each.to_a.join]
  end

  it "appends a random HTML comment to HTML responses over SSL" do
    status, _headers, body = call

    assert_equal 200, status
    assert body.start_with?("<html><body>Hello</body></html>")
    assert_match(/\n<!-- This is a random-length HTML comment: [a-z]* -->\z/, body)
  end

  it "varies the length of the padding" do
    lengths = 30.times.map { call.last.length }.uniq
    assert_operator lengths.size, :>, 10
  end

  it "never pads past the maximum length" do
    longest = 50.times.map { call.last.length }.max
    assert_operator longest, :<, "<html><body>Hello</body></html>".length + BreachLengthHiding::MAX_LENGTH + 100
  end

  it "also pads XHTML" do
    assert_match(/random-length HTML comment/, call(content_type: "text/xhtml").last)
  end

  it "leaves non-HTML responses alone" do
    _status, _headers, body = call(content_type: "application/json", body: '{"a":1}')
    assert_equal '{"a":1}', body
  end

  it "leaves responses alone when not over SSL" do
    assert_equal "<html><body>Hello</body></html>", call(https: false).last
  end

  it "is installed in the application's middleware stack before Rack::ETag" do
    stack = Rails.application.middleware.map(&:name)
    assert_includes stack, "BreachLengthHiding"
    assert_operator stack.index("BreachLengthHiding"), :<, stack.index("Rack::ETag")
  end
end
