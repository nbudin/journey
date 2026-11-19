class IndexPermissions < ActiveRecord::Migration[4.2]
  def self.up
    add_index :permissions, [:permissioned_type, :permissioned_id]
  end

  def self.down
    remove_index :permissions, [:permissioned_type, :permissioned_id]
  end
end
