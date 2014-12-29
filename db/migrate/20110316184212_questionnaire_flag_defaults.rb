class QuestionnaireFlagDefaults < ActiveRecord::Migration
  def self.up
    no_preview = Questionnaire.where(:allow_preview => false).find_each

    change_column :questionnaires, :allow_preview, :boolean, :null => false, :default => true
    transaction do
      no_preview.each do |q|
        q.allow_preview = false
        q.save(false)
      end
    end
    
    change_column :questionnaires, :allow_delete_responses, :boolean, :null => false, :default => false
  end

  def self.down
    change_column :questionnaires, :allow_preview, :boolean, :null => true, :default => nil
    change_column :questionnaires, :allow_delete_responses, :boolean, :null => true, :default => nil
  end
end
