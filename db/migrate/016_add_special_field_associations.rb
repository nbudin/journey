class AddSpecialFieldAssociations < ActiveRecord::Migration
  def self.up
    create_table :special_field_associations do |t|
      t.column :questionnaire_id, :integer
      t.column :question_id, :integer
      t.column :purpose, :string
    end
  end

  def self.down
    drop_table :special_field_associations
  end
end
