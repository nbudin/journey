class Return < ActiveRecord::Base
  belongs_to :questionnaire
end

class ReturnsToResponses < ActiveRecord::Migration
  def self.up
    create_table "responses" do |t|
      t.column "questionnaire_id", :integer, :default => 0, :null => false
    end
    Return.find(:all).each do |r|
      Response.create :id => r.id, :questionnaire_id => r.questionnaire_id
    end
    rename_column "answers", "return_id", "response_id"
    drop_table "returns"
  end

  def self.down
    create_table "returns" do |t|
      t.column "questionnaire_id", :integer, :default => 0, :null => false
    end
    Response.find(:all).each do |r|
      Return.create :id => r.id, :questionnaire_id => r.questionnaire_id
    end
    rename_column "answers", "response_id", "return_id"
    drop_table "responses"
  end
end
