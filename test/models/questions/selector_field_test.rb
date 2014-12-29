require 'test_helper'

class SelectorFieldTest < ActiveSupport::TestCase
  test "Selector fields should correctly detect numericality" do
    numeric_field = FactoryGirl.create :radio_field
    [-60, 1, 2, 3, 4, "5", 6.6].each { |n| numeric_field.question_options.create(option: n) }
    assert numeric_field.is_numeric?
    
    non_numeric_field = FactoryGirl.create :radio_field
    %w{a b c 1 2 3}.each { |n| non_numeric_field.question_options.create(option: n) }
    assert !non_numeric_field.is_numeric?
  end
  
  test "Selector fields should calculate min and max" do
    field = FactoryGirl.create :radio_field
    [-60.1, 1, 2, 3, 4, "5", 6.6].each { |n| field.question_options.create(option: n) }
    assert_equal -61, field.min  # floor of lowest value
    assert_equal 7, field.max    # ceiling of highest value
  end
end
