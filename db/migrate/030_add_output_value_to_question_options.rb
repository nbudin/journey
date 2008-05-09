class AddOutputValueToQuestionOptions < ActiveRecord::Migration
  def self.up
    add_column "question_options", "output_value", :string
  end

  def self.down
    remove_column "question_options", "output_value"
  end
end
