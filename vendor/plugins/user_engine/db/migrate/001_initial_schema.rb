class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table UserEngine.config(:permission_table), :force => true do |t|
      t.column "controller", :string, :default => "", :null => false
      t.column "action", :string, :default => "", :null => false
      t.column "description", :string
    end

    create_table UserEngine.config(:permission_role_table), :id => false, :force => true do |t|
      t.column "permission_id", :integer, :default => 0, :null => false
      t.column "role_id", :integer, :default => 0, :null => false
    end

    create_table UserEngine.config(:user_role_table), :id => false, :force => true do |t|
      t.column "user_id", :integer, :default => 0, :null => false
      t.column "role_id", :integer, :default => 0, :null => false
    end

    create_table UserEngine.config(:role_table), :force => true do |t|
      t.column "name", :string, :default => "", :null => false
      t.column "description", :string
    end
  end

  def self.down
    remove_table UserEngine.config(:permission_table)
    remove_table UserEngine.config(:permission_role_table)
    remove_table UserEngine.config(:user_role_table)
    remove_table UserEngine.config(:role_table)
  end
end
