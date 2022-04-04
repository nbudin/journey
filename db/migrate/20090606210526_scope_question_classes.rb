class ScopeQuestionClasses < ActiveRecord::Migration
  class Question < ApplicationRecord
    self.inheritance_column = nil
  end

  # have to do this in SQL, because we're breaking STI here
  def self.up
    Question.where("type is not null and type != ?", "Question").find_each do |q|
      q.update_attributes(type: "Questions::#{q.type}")
    end
  end

  def self.down
    Question.where("type is not null and type != ?", "Question").find_each do |q|
      q.update_attributes(type: q.type.sub(/\AQuestions::/, ''))
    end
  end
end
