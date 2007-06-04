class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.column :role_id, :integer, :null => false
      t.column :permission, :string
      t.column :permissioned_id, :integer
      t.column :permissioned_type, :string
    end
  end

  def self.down
    drop_table :permissions
  end
end
