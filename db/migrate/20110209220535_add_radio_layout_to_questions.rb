class AddRadioLayoutToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :radio_layout, :string, :null => false, :default => "inline"
  end

  def self.down
    remove_column :questions, :radio_layout
  end
end
