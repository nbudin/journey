class CreateEntitlements < ActiveRecord::Migration
  def self.up
    create_table :entitlements do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :entitlements
  end
end
