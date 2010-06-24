class AllowNullForAssociationFields < ActiveRecord::Migration
  def self.up
    change_column :pages, "questionnaire_id", :integer, :default => 0, :null => false
    change_column :question_options, "question_id", :integer, :default => 0, :null => false
    change_column :questions, "page_id", :integer, :default => 0, :null => false
  end

  def self.down
    change_column :pages, "questionnaire_id", :integer, :null => false
    change_column :question_options, "question_id", :integer, :null => false
    change_column :questions, "page_id", :integer, :null => false
  end
end
