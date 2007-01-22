class CreateCheckouts < ActiveRecord::Migration
  def self.up
    create_table :checkouts do |t|
      t.column :project_id, :integer
      t.column :user_id, :integer
      t.column :path, :string
    end
  end

  def self.down
    drop_table :checkouts
  end
end
