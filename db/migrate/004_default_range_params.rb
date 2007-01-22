class DefaultRangeParams < ActiveRecord::Migration
  def self.up
    change_column "questions", "min", :integer, :default => 0, :null => false
    change_column "questions", "max", :integer, :default => 0, :null => false
    change_column "questions", "step", :integer, :default => 1, :null => false
  end

  def self.down
    change_column "questions", "min", :integer
    change_column "questions", "max", :integer
    change_column "questions", "step", :integer
  end
end
