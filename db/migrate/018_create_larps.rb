class CreateLarps < ActiveRecord::Migration
  def self.up
    create_table :larps do |t|
      t.column :name, :string
    end
  end

  def self.down
    drop_table :larps
  end
end
