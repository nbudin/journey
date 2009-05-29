class Pages < ActiveRecord::Migration
  def self.up
    create_table "questionnaires", :force => true do |t|
      t.column "title", :text
      t.column "open", :boolean
    end

    create_table "questions", :force => true do |t|
      t.column "type", :string, :limit => 100, :default => "", :null => false
      t.column "position", :integer, :default => 0, :null => false
      t.column "caption", :text, :null => false
      t.column "required", :boolean, :default => false, :null => false
      t.column "min", :integer, :default => 0, :null => false
      t.column "max", :integer, :default => 0, :null => false
      t.column "step", :integer, :default => 1, :null => false
      t.column "questionnaire_id", :integer, :null => false
    end

    create_table :pages, :force => true do |t|
      t.column :questionnaire_id, :integer, :null => false
      t.column :position, :integer
    end

    create_table :question_options, :force => true do |t|
      t.column "question_id", :integer, :null => false
      t.column "option", :text, :null => false
      t.column "position", :integer, :null => false
    end

    add_column :questions, :page_id, :integer, :null => false
    remove_column :questions, :questionnaire_id
  end

  def self.down
    add_column :questions, :questionnaire_id, :integer, :default => 0, :null => false
#    Question.find(:all).each do |question|
#      question.questionnaire_id = question.page.questionnaire.id
#    end
    remove_column :questions, :page_id
    drop_table :pages
    drop_table :questions
    drop_table :questionnaires
    drop_table :question_options
  end
end
