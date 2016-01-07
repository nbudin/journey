class MakeCustomCssUnlimitedLength < ActiveRecord::Migration
  def up
    change_column :questionnaires, :custom_html, :text
    change_column :questionnaires, :custom_css, :text
  end

  def down
    change_column :questionnaires, :custom_html, :string, default: ""
    change_column :questionnaires, :custom_css, :string, default: ""
  end
end
