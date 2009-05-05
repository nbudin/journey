require 'test_helper'

class ScoutUtilsTest < ActiveSupport::TestCase
  
  # # Fixes the runtimes to be in milliseconds.
  # # 
  # def fix_runtimes_to_ms!(runtimes)
  #   [:view, :total].each do |key|
  #     runtimes[key] = seconds_to_ms(runtimes[key])
  #   end
  # end
  # 
  # # Fix times in seconds to time in milliseconds.
  # # 
  # def seconds_to_ms(n)
  #   n * 1000.0
  # end
  
  def test_runtimes_are_fixed_to_ms
    runtimes = {:view => 0.00004, :total => 0.0008}
    
    fixed_runtimes = runtimes.dup
    assert Scout.fix_runtimes_to_ms!(fixed_runtimes)
    
    assert_equal runtimes[:view] * 1000, fixed_runtimes[:view]
    assert_equal runtimes[:total] * 1000, fixed_runtimes[:total]
  end
  
  def test_seconds_can_be_converted_to_ms
    # assert false
  end
  
  def test_obfuscate_sql_handles_a_variety_of_queries_correctly
    assert_equal "SELECT * FROM actors WHERE id = ?;", Scout.obfuscate_sql("SELECT * FROM actors WHERE id = 10;")
    assert_equal "SELECT * FROM actors WHERE name LIKE ?;", Scout.obfuscate_sql("SELECT * FROM actors WHERE name LIKE '%jones%';")
    assert_equal "SELECT * FROM actors WHERE secret = ?;", Scout.obfuscate_sql("SELECT * FROM actors WHERE secret = 'bee''s nees';")
  end
  
end
