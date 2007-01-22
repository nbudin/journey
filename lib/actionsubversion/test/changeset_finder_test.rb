require 'test_util'
require 'time'

class Repos < ActionSubversion::Base
end

class ChangesetFinderTest < Test::Unit::TestCase
  include ActionSubversionTestUtil

  def setup
    setup_repos
    @changeset1 = Repos.get_changeset(1)
    @changeset2 = Repos.get_changeset(2)
    @changeset3 = Repos.get_changeset(3)
    #@changeset4 = Repos.get_changeset(4)
    @changeset5 = Repos.get_changeset(5)
    @changeset6 = Repos.get_changeset(6)
    @changeset7 = Repos.get_changeset(7)
  end
  
  def test_changeset_1_props
    assert_equal 'johan', @changeset1.author
    assert_equal 'importing test data', @changeset1.log_message
    #thetime = Time.parse("Sat May 28 22:58:00 CEST 2005")
    #assert_equal thetime, @changeset1.date
    assert_equal Time, @changeset1.date.class
    exp_nodes = ["html/", 
                "file1.txt", 
                "html/html_file.html", 
                "html_file.html", 
                "ruby.rb", 
                "urandom.bin", 
                "xaa"]
    assert_equal exp_nodes, @changeset1.added_nodes
  end

  def test_changeset_1
    assert_equal 'johan', @changeset1.author
    assert_equal 'importing test data', @changeset1.log_message
    assert_equal Time, @changeset1.date.class
    exp_nodes = ["html/", 
                "file1.txt", 
                "html/html_file.html", 
                "html_file.html", 
                "ruby.rb", 
                "urandom.bin", 
                "xaa"]
    assert_equal exp_nodes, @changeset1.added_nodes
  end
  
  def test_changeset_2
    assert_equal 'johan', @changeset2.author
    assert_equal 'edited file1.txt', @changeset2.log_message
    assert_equal Time, @changeset2.date.class
    assert_equal ['file1.txt'], @changeset2.updated_nodes
  end
  
  def test_changeset_3
    assert_equal 'johan', @changeset3.author
    assert_equal 'edited file1.txt again', @changeset3.log_message
    assert_equal Time, @changeset3.date.class
    assert_equal ['file1.txt'], @changeset3.updated_nodes
  end
  
  def test_changeset_5_copyfile
    assert_equal [["file1-copy.txt", "file1.txt", 4]], @changeset5.copied_nodes
    assert_equal [], @changeset5.moved_nodes
    assert_equal [], @changeset5.added_nodes
    assert_equal [], @changeset5.deleted_nodes
    assert_equal [], @changeset5.updated_nodes
  end
  
  def test_changeset_6_copydir
    assert_equal [["new_dir-copy/", "new_dir/", 4]], @changeset6.copied_nodes
    assert_equal [], @changeset6.moved_nodes
    assert_equal [], @changeset6.added_nodes
    assert_equal [], @changeset6.deleted_nodes
    assert_equal [], @changeset6.updated_nodes
  end
  
  def test_changeset_7_copydir_and_copy_file
    exp = [["new_dir-copy2/", "new_dir/", 4], ["ruby-copy.rb", "ruby.rb", 4]]
    assert_equal exp, @changeset7.copied_nodes
    assert_equal [], @changeset7.moved_nodes
    assert_equal [], @changeset7.added_nodes
    assert_equal [], @changeset7.deleted_nodes
    assert_equal [], @changeset7.updated_nodes
  end
  
  def test_changeset_8_copytwodirs
    exp = [["new_dir-copy3/", "new_dir/", 4], ["new_dir-copy4/", "new_dir-copy/", 6]]
    assert_equal exp, Repos.get_changeset(8).copied_nodes
    assert_equal [], Repos.get_changeset(8).moved_nodes
    assert_equal [], Repos.get_changeset(8).added_nodes
    assert_equal [], Repos.get_changeset(8).deleted_nodes
    assert_equal [], Repos.get_changeset(8).updated_nodes
  end
  
  def test_changeset_9_movefileanddir
    exp = [["moved_dir/", "new_dir-copy4/", 8], ["random-bins.bin", "urandom.bin", 4]]
    assert_equal exp, Repos.get_changeset(9).moved_nodes
    assert_equal [], Repos.get_changeset(9).copied_nodes
    assert_equal [], Repos.get_changeset(9).added_nodes
    assert_equal [], Repos.get_changeset(9).deleted_nodes
    assert_equal [], Repos.get_changeset(9).updated_nodes
  end
  
  def test_changeset_10_copy_and_move
    assert_equal [["file1copy.txt", "file1-copy.txt", 5]], Repos.get_changeset(10).moved_nodes
    assert_equal [["somefile.txt", "file1.txt", 4]], Repos.get_changeset(10).copied_nodes
    assert_equal [], Repos.get_changeset(10).added_nodes
    assert_equal [], Repos.get_changeset(10).deleted_nodes
    assert_equal [], Repos.get_changeset(10).updated_nodes
  end
  
  def test_changeset_11_copy_and_move_and_delete
    assert_equal [["file1-copy.txt", "file1.txt", 4]], Repos.get_changeset(11).moved_nodes
    assert_equal [["file.txt", "somefile.txt", 10]], Repos.get_changeset(11).copied_nodes
    assert_equal [], Repos.get_changeset(11).added_nodes
    assert_equal ["file1copy.txt"], Repos.get_changeset(11).deleted_nodes
    assert_equal [], Repos.get_changeset(11).updated_nodes
  end

  def teardown
    teardown_repos
  end
end