require 'test_helper'

class TinymceAssetsTest < ActionDispatch::IntegrationTest
  # TinyMCE's skin CSS requests its icon font from /fonts/..., but the files live under /assets/tinymce/...
  %w(tinymce.woff tinymce.ttf tinymce.eot tinymce.svg tinymce-small.woff).each do |font|
    test "redirects /fonts/#{font} to the published TinyMCE font" do
      get "/fonts/#{font}"

      assert_response :redirect
      assert_equal "/assets/tinymce/skins/lightgray/fonts/#{font}", URI(response.location).path
    end
  end

  test "does not redirect other font requests" do
    get "/fonts/something-else.woff"
    assert_response :not_found
  end

  test "configures the editor's content stylesheet from the asset pipeline" do
    config = TinyMCE::Rails.configuration.options_for_tinymce
    assert_match %r{\A/assets/questionnaire(-[0-9a-f]{64})?\.css\z}, config["content_css"]
  end
end
