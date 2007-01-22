class DestroyAnswerOptions < ActiveRecord::Migration
  def self.up
    drop_table "answer_options"
  end

  def self.down
    create_table "answer_options", :id => false, :force => true do |t|
      t.column "answer_id", :integer, :default => 0, :null => false
      t.column "option_id", :integer, :default => 0, :null => false
      t.column "value", :boolean, :default => false, :null => false
    end
  end
end
