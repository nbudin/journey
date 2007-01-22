require 'test_util'

class Repos < ActionSubversion::Base
end

class MimeFinderTest < Test::Unit::TestCase
  include ActionSubversionTestUtil

  def setup
    setup_repos
  end

  def test_find_by_extensions
    # this feels kinda superfluous
    ActionSubversion::MimeFinder::ClassMethods::VIEWABLE_FILE_EXTENSIONS.each do |ext|
      assert_equal ext[1], Repos.get_mime_type_by_extension('filename.' + ext[0])
    end
  end
  
  def test_file_without_extension
    assert_equal 'text/plain', Repos.get_mime_type_by_extension('filewithoutextension')
  end
  
  def teardown
    teardown_repos
  end
  
end 