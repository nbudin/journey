require 'test_helper'
require 'minitest/mock'

# Rollbar hooks into Rails' exception rendering.  When a Rails upgrade changed the signature of the method it wraps,
# every exception turned into a plain 500 (and wasn't reported) while the rest of the suite stayed green, because
# tests normally raise exceptions instead of rendering the error pages.  Render them for real here.
class ErrorPagesTest < ActionDispatch::IntegrationTest
  before do
    @saved_env_config = Rails.application.env_config.slice("action_dispatch.show_exceptions", "action_dispatch.show_detailed_exceptions")
    Rails.application.env_config["action_dispatch.show_exceptions"] = :all
    Rails.application.env_config["action_dispatch.show_detailed_exceptions"] = false
  end

  after do
    Rails.application.env_config.merge!(@saved_env_config)
  end

  it "renders the 404 page for a path that doesn't exist" do
    get "/nonexistent"

    assert_response :not_found
    assert_includes response.body, "The page you were looking for doesn't exist"
  end

  it "renders the 404 page when a record isn't found" do
    get "/answer/0/prompt"

    assert_response :not_found
  end

  it "renders the 500 page for an unhandled error" do
    Questionnaire.stub(:find, ->(*) { raise "something broke" }) do
      get "/answer/1/prompt"
    end

    assert_response :internal_server_error
    assert_includes response.body, "something went wrong"
  end

  it "rejects a request with a bad CSRF token with the same error handling" do
    ActionController::Base.stub(:allow_forgery_protection, true) do
      post "/answer/1/save_answers", params: { authenticity_token: "bogus" }
    end

    assert_includes [404, 422], response.status
  end
end
