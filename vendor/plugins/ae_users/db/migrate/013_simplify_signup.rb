class SimplifySignup < ActiveRecord::Migration
  def self.up
    rename_column "people", "home_phone", "phone"
    remove_column "people", "work_phone"
    remove_column "people", "address"
  end

  def self.down
    rename_column "people", "phone", "home_phone"
    add_column "people", "work_phone", :string
    add_column "people", "address", :string
  end
end
