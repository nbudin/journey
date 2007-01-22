class Pages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.column :questionnaire_id, :integer, :null => false
      t.column :position, :integer
    end
    Questionnaire.find(:all).each do |questionnaire|
      page = Page.create
      questionnaire.pages << questionnaire
    end
    add_column :questions, :page_id, :integer, :null => false
    Question.find(:all).each do |question|
      question.questionnaire.pages[0] << question
    end
    remove_column :questions, :questionnaire_id
  end

  def self.down
    add_column :questions, :questionnaire_id, :integer, :default => 0, :null => false
    Question.find(:all).each do |question|
      question.questionnaire_id = question.page.questionnaire.id
    end
    remove_column :questions, :page_id
    drop_table :pages
  end
end
