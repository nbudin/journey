class AddQuestionDefaults < ActiveRecord::Migration
  def self.up
    add_column :questions, :default_answer, :string
  end

  def self.down
    remove_column :questions, :default_answer
  end
end
