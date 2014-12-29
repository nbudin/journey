class AddPreviewableOptionToQuestionnaires < ActiveRecord::Migration
  def self.up
    add_column :questionnaires, :allow_preview, :boolean
    Questionnaire.where(:is_open => true).find_each do |q|
      q.allow_preview = true
      q.save :validate => false
    end
  end

  def self.down
    remove_column :questionnaires, :allow_preview
  end
end
