class MakeCustomCssUnlimitedLength < ActiveRecord::Migration[4.2]
  def up
    change_column :questionnaires, :custom_html, :text, default: nil
    change_column :questionnaires, :custom_css, :text, default: nil
  end

  def down
    change_column :questionnaires, :custom_html, :string, default: ""
    change_column :questionnaires, :custom_css, :string, default: ""
  end
end
