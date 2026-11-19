require 'test_helper'
require 'tmpdir'

# Reading an existing assets manifest only happens once one exists on disk (like in a deployed image, where assets are
# precompiled at build time), so a from-scratch precompile or the rest of the test suite would not notice if the
# Sprockets and json gems stopped getting along (Sprockets 3.7 broke on json 3 this way).
class AssetsManifestTest < ActiveSupport::TestCase
  test "Sprockets can load an existing manifest" do
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, ".sprockets-manifest-0123456789abcdef0123456789abcdef.json"), '{"files":{},"assets":{}}')

      manifest = Sprockets::Manifest.new(Rails.application.assets, dir)
      assert_equal({}, manifest.assets)
    end
  end
end
