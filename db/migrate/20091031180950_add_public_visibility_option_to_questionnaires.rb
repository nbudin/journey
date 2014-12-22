class AddPublicVisibilityOptionToQuestionnaires < ActiveRecord::Migration
  def self.up
    add_column :questionnaires, :publicly_visible, :boolean
    add_index :questionnaires, :publicly_visible
    
    Questionnaire.where(:is_open => true).find_each do |q|
      q.publicly_visible = true
      q.save :validate => false
    end
  end

  def self.down
    remove_column :questionnaires, :publicly_visible
  end
end
