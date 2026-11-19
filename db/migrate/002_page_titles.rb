class PageTitles < ActiveRecord::Migration[4.2]
  def self.up
    add_column :pages, :title, :string
  end

  def self.down
    remove_column :pages, :title
  end
end
