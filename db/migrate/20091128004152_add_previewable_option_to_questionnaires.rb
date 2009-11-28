class AddPreviewableOptionToQuestionnaires < ActiveRecord::Migration
  def self.up
    add_column :questionnaires, :allow_preview, :boolean
    Questionnaire.all(:conditions => { :is_open => true }).each do |q|
      q.allow_preview = true
      q.save :validate => false
    end
  end

  def self.down
    remove_column :questionnaires, :allow_preview
  end
end
