class Page < ActiveRecord::Base
  belongs_to :questionnaire
  acts_as_list :scope => :questionnaire_id
  has_many :questions, :order => :position
  
  def self.title
    if self.attributes[:title].length > 0
      return self.attributes[:title]
    elsif self.questionnaire.pages.length == 1
      return ""
    else
      return "Page "+self.position
    end
  end
end