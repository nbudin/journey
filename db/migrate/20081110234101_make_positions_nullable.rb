class MakePositionsNullable < ActiveRecord::Migration
  def self.up
    change_column :question_options, :position, :integer, :default => 0, :null => true
    change_column :questions, :position, :integer, :default => 0, :null => true
  end

  def self.down
    change_column :question_options, :position, :integer, :default => 0, :null => false
    change_column :questions, :position, :integer, :default => 0, :null => false
  end
end
