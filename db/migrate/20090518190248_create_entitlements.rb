class CreateEntitlements < ActiveRecord::Migration
  def self.up
    create_table :entitlements do |t|
      t.integer :person_id
      t.boolean :unlimited
      t.timestamp :expires_at
      t.integer :open_questionnaires
      t.integer :responses_per_month
      t.timestamps
    end

    add_index :entitlements, :person_id
  end

  def self.down
    drop_table :entitlements
  end
end
