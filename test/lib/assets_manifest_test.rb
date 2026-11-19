require 'test_helper'
require 'tmpdir'

# Sprockets 3.7 reads an existing assets manifest with JSON.parse(create_additions: false), which the json 3 gem
# rejects.  That only breaks once a manifest exists on disk (like in a deployed image, where assets are precompiled
# at build time), so a from-scratch precompile or the test suite alone would not notice.
class AssetsManifestTest < ActiveSupport::TestCase
  test "Sprockets can load an existing manifest" do
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, ".sprockets-manifest-0123456789abcdef0123456789abcdef.json"), '{"files":{},"assets":{}}')

      manifest = Sprockets::Manifest.new(Rails.application.assets, dir)
      assert_equal({}, manifest.assets)
    end
  end
end
