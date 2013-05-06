class MakeSpecialFieldPurposesUnique < ActiveRecord::Migration
  def self.up
    add_index :special_field_associations, [:questionnaire_id, :purpose], :unique => true
  end

  def self.down
    remove_index :special_field_associations, [:questionnaire_id, :purpose]
  end
end
