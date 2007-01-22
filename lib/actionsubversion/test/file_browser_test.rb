require 'test_util'

class Repos < ActionSubversion::Base
end

class FileBrowserTest < Test::Unit::TestCase
  include ActionSubversionTestUtil
  
  def setup
    setup_repos
    @root_entries = Repos.get_node_entries('/')
  end

  def test_view_nodes_and_their_attrs
    assert_equal Array, @root_entries.class
    assert_equal ActionSubversion::RepositoryNode, @root_entries.first.class
    assert_equal "copied a file. moved another file.\n", @root_entries.first.log
    
    assert_equal 1, @root_entries.last.revision
    assert_equal 'johan', @root_entries.last.author
    assert_equal 'text/html', @root_entries.last.mime_type
    assert_equal 'html_file.html', @root_entries.last.name
    assert_equal '/html_file.html', @root_entries.last.path
    assert_equal 'importing test data', @root_entries.last.log
    assert_equal 'importing test data', @root_entries.last.log_message
    assert_equal 96, @root_entries.last.size
    assert_equal Time, @root_entries.last.date.class
    assert_equal 'Sat May 28 22:58:00 CEST 2005', @root_entries.last.date.to_s
    assert @root_entries.last.file?
    assert !@root_entries.last.dir?
    
    #file1 = @root_entries.find {|e| e.name == "file.txt"}
    #assert_equal 11, file1.revision
    #assert_equal "deleted a file + moved a file + copied a file\n", file1.log
  end
  
  def test_is_dir
    assert Repos.is_dir?('html')
    assert !Repos.is_dir?('file1.txt')
  end
  
  def test_rev_can_be_string
    node = nil
    assert_nothing_raised {
      node = Repos.get_node_entry('file1.txt', '3')
    }
    node_again = Repos.get_node_entry('file1.txt', 3)
    assert_equal node.revision, node_again.revision
  end
  
  def test_get_mime_type
    assert_equal 'text/html', Repos.get_mime_type('/html/html_file.html')
    assert_equal 'text/x-ruby', Repos.get_mime_type('ruby.rb')
    #assert_equal 'application/octet-stream', Repos.get_mime_type('random-bins.bin')
    # test to see if file without extension gets the text/plain mimetype
    assert_equal 'text/plain', Repos.get_mime_type('xaa')
  end
  
  def test_get_contents
    expected_content = "I am the silly test file!\n"
    assert_equal expected_content, Repos.get_file_contents('file.txt')
  end
  
  def test_get_node_entry
    entry = Repos.get_node_entry('/')
    assert_equal ActionSubversion::RepositoryNode, entry.class
    assert_equal '/', entry.name
    assert_equal '/', entry.path
  end
  
  def teardown
    teardown_repos
  end
end