class ReturnsToResponses < ActiveRecord::Migration
  def self.up
    create_table "answers", :force => true do |t|
      t.column "response_id", :integer
      t.column "question_id", :integer, :default => 0, :null => false
      t.column "value", :text
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end
    create_table "responses" do |t|
      t.column "questionnaire_id", :integer, :default => 0, :null => false
    end
  end

  def self.down
    drop_table "responses"
    drop_table "answers"
  end
end
