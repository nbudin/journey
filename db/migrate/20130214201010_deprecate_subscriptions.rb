class DeprecateSubscriptions < ActiveRecord::Migration
  def self.up
    return unless table_exists? :subscriptions

    create_table :subscription_permissions do |t|
      t.references :subscription
      t.references :person
      t.references :role
      t.string :permission
    end
      
    execute <<-EOF
    INSERT INTO subscription_permissions (subscription_id, person_id, role_id, permission) 
    SELECT permissioned_id, person_id, role_id, permission
    FROM permissions
    WHERE permissioned_type = #{connection.quote "Subscription"}
    EOF
    
    execute "DELETE FROM permissions WHERE permissioned_type = #{connection.quote "Subscription"}"
  end

  def self.down
    return unless table_exists? :subscriptions

    execute <<-EOF
    INSERT INTO permissions (permissioned_id, permissioned_type, person_id, role_id, permission) 
    SELECT #{connection.quote "Subscription"}, subscription_id, person_id, role_id, permission
    FROM subscription_permissions
    EOF
    
    drop_table :subscription_permissions
  end
end
