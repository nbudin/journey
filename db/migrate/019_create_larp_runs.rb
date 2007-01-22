class CreateLarpRuns < ActiveRecord::Migration
  def self.up
    create_table :larp_runs do |t|
      t.column :larp_id, :integer
      t.column :venue, :string
      t.column :when, :datetime
    end
  end

  def self.down
    drop_table :larp_runs
  end
end
