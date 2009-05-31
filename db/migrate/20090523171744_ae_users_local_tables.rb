class AeUsersLocalTables < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.column :role_id, :integer
      t.column :person_id, :integer
      t.column :permission, :string
      t.column :permissioned_id, :integer
      t.column :permissioned_type, :string
    end
    
    create_table :auth_tickets do |t|
      t.column :secret, :string
      t.column :person_id, :integer
      t.timestamps
      t.column :expires_at, :datetime
    end

    add_index :auth_tickets, :secret, :unique => true
  end

  def self.down
    drop_table :auth_tickets
    drop_table :permissions
  end
end
