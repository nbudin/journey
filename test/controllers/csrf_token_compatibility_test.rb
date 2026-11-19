require 'test_helper'

# Rails 7.0 changed CSRF token encoding to unpadded URL-safe base64.  People with a form open from before a deploy
# submit tokens in the old format (padded standard base64), and their session holds the old format too, so make sure
# those are still accepted.  (Forgery protection is off in the test environment, so this checks the token
# verification directly.)
class CsrfTokenCompatibilityTest < ActionController::TestCase
  tests AnswerController

  def xor(a, b)
    a.bytes.zip(b.bytes).map { |x, y| x ^ y }.pack("C*")
  end

  def old_format_masked(raw)
    pad = SecureRandom.random_bytes(32)
    Base64.strict_encode64(pad + xor(pad, raw))
  end

  before do
    get :prompt, params: { id: FactoryGirl.create(:questionnaire, is_open: true).id }
    @raw = SecureRandom.random_bytes(32)

    # The session holds the token in the old format (padded standard base64).  Rails 7.1 ignores the session
    # argument to valid_authenticity_token? and reads the token from the request, so put it there (and clear
    # the copy Rails caches in the request environment).
    @session = { _csrf_token: Base64.strict_encode64(@raw) }
    request.session[:_csrf_token] = @session[:_csrf_token]
    request.env.delete(ActionController::RequestForgeryProtection::CSRF_TOKEN)
  end

  it "accepts a masked token issued in the old format" do
    assert @controller.send(:valid_authenticity_token?, @session, old_format_masked(@raw))
  end

  it "accepts an unmasked token issued in the old format" do
    assert @controller.send(:valid_authenticity_token?, @session, Base64.strict_encode64(@raw))
  end

  it "accepts a masked token in the new format" do
    pad = SecureRandom.random_bytes(32)
    assert @controller.send(:valid_authenticity_token?, @session, Base64.urlsafe_encode64(pad + xor(pad, @raw), padding: false))
  end

  it "rejects a token for a different session" do
    refute @controller.send(:valid_authenticity_token?, @session, old_format_masked(SecureRandom.random_bytes(32)))
  end

  it "does compare against this session's token (a token for another session must fail, this one must pass)" do
    assert @controller.send(:valid_authenticity_token?, @session, old_format_masked(@raw))
    refute @controller.send(:valid_authenticity_token?, @session, old_format_masked(@raw.reverse))
  end

  it "rejects garbage" do
    refute @controller.send(:valid_authenticity_token?, @session, "not a token")
    refute @controller.send(:valid_authenticity_token?, @session, "")
  end
end
