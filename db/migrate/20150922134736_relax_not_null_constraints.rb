class RelaxNotNullConstraints < ActiveRecord::Migration[4.2]
  def change
    change_table :questions do |t|
      t.change :min, :integer, null: true, default: 0
      t.change :max, :integer, null: true, default: 0
    end
  end
end
