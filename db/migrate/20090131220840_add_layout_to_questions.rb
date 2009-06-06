class AddLayoutToQuestions < ActiveRecord::Migration
  def self.up
    # cope with the scoping transition
    btf_class = nil
    begin
      btf_class = BigTextField
    rescue
      btf_class = Questions::BigTextField
    end
    
    add_column :questions, :layout, :string, :default => "left"
    Question.find(:all).each do |q|
      if q.kind_of? btf_class
        q.layout = "top"
        q.save
      end
    end
  end

  def self.down
    remove_column :questions, :layout
  end
end
