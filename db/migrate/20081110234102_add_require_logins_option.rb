class AddRequireLoginsOption < ActiveRecord::Migration[4.2]
  def self.up
    add_column :questionnaires, :require_login, :boolean, :default => false
  end

  def self.down
    remove_column :questionnaires, :require_login
  end
end
