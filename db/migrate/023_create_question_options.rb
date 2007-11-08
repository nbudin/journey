class CreateQuestionOptions < ActiveRecord::Migration
  def self.up
    create_table :question_options do |t|
    end
  end

  def self.down
    drop_table :question_options
  end
end
