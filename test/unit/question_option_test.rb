require 'test_helper'

class QuestionOptionTest < ActiveSupport::TestCase
  test "effective_output_value should return output_value if present and default to the option if not" do
    option = FactoryGirl.create(:question_option, option: "blue")
    assert_equal "blue", option.effective_output_value
    
    option.update_attributes(output_value: "orange")
    assert_equal "orange", option.effective_output_value
  end
end
