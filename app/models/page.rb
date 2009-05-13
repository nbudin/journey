require 'journey_questionnaire'

class Page < ActiveRecord::Base
  belongs_to :questionnaire
  acts_as_list :scope => :questionnaire_id
  has_many :questions, :order => :position, :dependent => :destroy, :include => [:page, :question_options]
  has_many :fields, :class_name => 'Question', :order => :position,
    :conditions => "type in #{Journey::Questionnaire::types_for_sql(Journey::Questionnaire::field_types)}"
  has_many :decorators, :class_name => 'Question', :order => :position,
    :conditions => "type in #{Journey::Questionnaire::types_for_sql(Journey::Questionnaire::decorator_types)}"
  
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
