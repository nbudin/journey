require 'test_util'

class Repos < ActionSubversion::Base
end

class FileDiffTest < Test::Unit::TestCase
  include ActionSubversionTestUtil
  
  def setup
    setup_repos
  end
  
  def test_udiff
    diff = Repos.unified_diff('file1.txt', 3)
    expected_diff = "--- Revision 2\n+++ Revision 3\n@@ -1 +1 @@\n-not any more\n+I am the silly test file!\n"
    assert_equal expected_diff, diff
  end
  
  def teardown
    teardown_repos 
  end
  
end