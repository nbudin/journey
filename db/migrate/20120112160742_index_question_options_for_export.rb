class IndexQuestionOptionsForExport < ActiveRecord::Migration
  def self.up
    add_index :question_options, [:question_id, :option], :length => { :option => 10 }
  end

  def self.down
    remove_index :question_options, [:question_id, :option]
  end
end
