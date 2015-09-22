class RelaxNotNullConstraints < ActiveRecord::Migration
  def change
    change_table :questions do |t|
      t.change :min, :integer, null: true, default: 0
      t.change :max, :integer, null: true, default: 0
    end
  end
end
