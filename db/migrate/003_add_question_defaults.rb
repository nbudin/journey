class AddQuestionDefaults < ActiveRecord::Migration[4.2]
  def self.up
    add_column :questions, :default_answer, :string
  end

  def self.down
    remove_column :questions, :default_answer
  end
end
