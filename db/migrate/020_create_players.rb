class CreatePlayers < ActiveRecord::Migration
  def self.up
    create_table :players, :id => false do |t|
      t.column :larp_run_id, :integer
      t.column :user_id, :integer
    end
    add_index :players, [:larp_run_id, :user_id], :unique => true
  end

  def self.down
    drop_table :players
  end
end
