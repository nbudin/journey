class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.column :name, :string, :null => false
      t.column :repo_url, :string, :null => false
      t.column :username, :string
      t.column :password, :string
    end
  end

  def self.down
    drop_table :projects
  end
end
