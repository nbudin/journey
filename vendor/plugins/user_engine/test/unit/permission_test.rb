require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  
  def test_table_name
    assert_equal UserEngine.config(:permission_table_name), Permission.table_name
  end

  def test_path
    assert_equal "hello/", Permission.new(:controller => "hello").path
    assert_equal "hello/world", Permission.new(:controller => "hello", :action => "world").path
    assert_equal "hello/you/monkey", Permission.new(:controller => "hello/you", :action => "monkey").path
  end
    
end
