require 'test_util'
require 'time'

class RepositoryNodeTest < Test::Unit::TestCase
  include ActionSubversionTestUtil
  
  def setup
    setup_repos
    @fs = ActionSubversion::Base.fs
    @node = ActionSubversion::RepositoryNode.new('html_file.html', @fs)
  end  
  
  def test_path_will_always_be_canonical
    repos = nil
    assert_nothing_raised { repos = ActionSubversion::SvnRepository.new(@full_repos_path) }
    assert_not_nil repos
  end
  
  def test_non_canonical_path_will_always_be_canonical
    repos = nil
    assert_nothing_raised { repos = ActionSubversion::SvnRepository.new(@full_repos_path) }
    assert_not_nil repos
  end
  
  def test_get_past_revision
    rev_node = ActionSubversion::RepositoryNode.new('file1.txt', @fs, 3)
    past_rev_node = ActionSubversion::RepositoryNode.new('file1.txt', @fs, 1)
    assert_equal 3, rev_node.revision
    assert_equal 1, past_rev_node.revision
  end
  
  def test_node_proplist
    exp = {}
    assert_equal exp, @node.proplist
    # TODO: more proplist tests
  end

  def test_path
    assert_equal 'html_file.html', @node.path
    n = ActionSubversion::RepositoryNode.new('/html/html_file.html', @fs)
    assert_equal '/html/html_file.html', n.path
  end
  
  def test_revision 
    assert_equal 1, @node.revision
  end
  
  def test_name
    assert_equal 'html_file.html', @node.name
  end
  
  def test_is_dir
    assert !@node.dir?
  end
  
  def test_is_file
    assert @node.file?
  end
  
  def test_is_textual
    assert @node.is_textual?
  end
  
  def test_is_image
    assert !@node.is_image?
  end
  
  def test_is_binary
    assert !@node.is_binary?
  end

  def test_author
    assert_equal 'johan', @node.author
  end

  def test_date
    assert_equal Time, @node.date.class
    expected_date = Time.parse('Sat May 28 22:58:00 CEST 2005')
    assert_equal expected_date.to_s, @node.date.to_s
  end

  def test_log
    assert_equal 'importing test data', @node.log
  end

  def test_mime_type
    assert_equal 'text/html', @node.mime_type
  end
  
  def test_contents
    expected = "<html>\n\t<head>\n\t\t<title>html test doc</title>\n\t</head>\n<body>\n\t<h1>Header!</h1>\n</body>\n</html>\n"
    assert_equal expected, @node.contents
  end
  
  def test_size
    assert_equal 96, @node.size
  end
  
  def teardown
    teardown_repos 
  end
  
end