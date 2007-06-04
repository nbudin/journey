class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.column :firstname, :string
      t.column :lastname, :string
      t.column :gender, :string
      t.column :nickname, :string
      t.column :address, :string
      t.column :home_phone, :string
      t.column :work_phone, :string
      t.column :best_call_time, :string
      t.column :birthdate, :datetime
      t.column :account_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :people
  end
end
