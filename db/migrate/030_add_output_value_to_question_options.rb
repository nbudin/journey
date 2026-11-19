class AddOutputValueToQuestionOptions < ActiveRecord::Migration[4.2]
  def self.up
    add_column "question_options", "output_value", :string
  end

  def self.down
    remove_column "question_options", "output_value"
  end
end
