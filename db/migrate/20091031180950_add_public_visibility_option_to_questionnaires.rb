class AddPublicVisibilityOptionToQuestionnaires < ActiveRecord::Migration
  def self.up
    add_column :questionnaires, :publicly_visible, :boolean
    add_index :questionnaires, :publicly_visible
    
    Questionnaire.all(:conditions => {:is_open => true}).each do |q|
      q.publicly_visible = true
      q.save :validate => false
    end
  end

  def self.down
    remove_column :questionnaires, :publicly_visible
  end
end
