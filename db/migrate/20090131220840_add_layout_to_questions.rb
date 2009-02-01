class AddLayoutToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :layout, :string, :default => "left"
    Question.find(:all).each do |q|
      if q.kind_of? BigTextField
        q.layout = "top"
        q.save
      end
    end
  end

  def self.down
    remove_column :questions, :layout
  end
end
