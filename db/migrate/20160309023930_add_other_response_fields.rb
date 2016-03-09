class AddOtherResponseFields < ActiveRecord::Migration
  def change
    add_column :question_options, :is_other, :boolean, null: false, default: false
    add_column :answers, :other_value, :text
  end
end
