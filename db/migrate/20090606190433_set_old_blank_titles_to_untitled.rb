class SetOldBlankTitlesToUntitled < ActiveRecord::Migration
  def self.up
    Questionnaire.all.each do |q|
      if q.title.blank?
        q.title = "Untitled survey"
        q.save
      end
    end
  end

  def self.down
    Questionnaire.all.each do |q|
      if q.title == "Untitled survey"
        q.title = ""
        q.save
      end
    end
  end
end
