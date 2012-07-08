class AddClosesAtToQuestionnaires < ActiveRecord::Migration
  def self.up
    add_column :questionnaires, :closes_at, :datetime
  end

  def self.down
    remove_column :questionnaires, :closes_at
  end
end
