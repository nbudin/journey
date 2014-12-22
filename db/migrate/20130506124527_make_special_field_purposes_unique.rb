class MakeSpecialFieldPurposesUnique < ActiveRecord::Migration
  def self.up
    add_index :special_field_associations, [:questionnaire_id, :purpose], :unique => true, name: 'idx_special_field_associations_unique'
  end

  def self.down
    remove_index :special_field_associations, name: 'idx_special_field_associations_unique'
  end
end
