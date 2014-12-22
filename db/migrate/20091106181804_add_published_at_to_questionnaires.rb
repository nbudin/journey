class AddPublishedAtToQuestionnaires < ActiveRecord::Migration
  def self.up
    add_column :questionnaires, :published_at, :timestamp
    Questionnaire.where(:is_open => true).find_each do |q|
      q.published_at = q.created_at
      q.save :validate => false
    end
  end

  def self.down
    remove_column :questionnaires, :published_at
  end
end
