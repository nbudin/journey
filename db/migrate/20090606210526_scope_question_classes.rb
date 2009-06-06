class ScopeQuestionClasses < ActiveRecord::Migration
  # have to do this in SQL, because we're breaking STI here
  def self.up
    execute "update questions set type = concat('Questions::', type) where type is not null and type != 'Question';"
  end

  def self.down
    execute "update questions set type = replace(type, 'Questions::', '') where type is not null;"
  end
end
