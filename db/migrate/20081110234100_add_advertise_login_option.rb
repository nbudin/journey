class AddAdvertiseLoginOption < ActiveRecord::Migration[4.2]
  def self.up
    add_column :questionnaires, :advertise_login, :boolean, :default => true
  end

  def self.down
    remove_column :questionnaires, :advertise_login
  end
end
