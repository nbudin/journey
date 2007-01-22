class CreateCharacters < ActiveRecord::Migration
  def self.up
    create_table :characters do |t|
      t.column :name, :string
      t.column :larp_id, :integer
    end
  end

  def self.down
    drop_table :characters
  end
end
