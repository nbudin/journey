class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
    end
  end

  def self.down
    drop_table :questions
  end
end
