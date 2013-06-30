require 'journey_questionnaire'

class Page < ActiveRecord::Base
  belongs_to :questionnaire
  acts_as_list :scope => :questionnaire_id
  
  before_create :set_untitled
  
  has_many :questions, :order => :position, :dependent => :destroy, :include => [:page, :question_options, :special_field_association]
  has_many :fields, :class_name => 'Question', :order => :position, :conditions => { :type => Question.field_types.map(&:name) }
  has_many :decorators, :class_name => 'Question', :order => :position, :conditions => { :type => Question.decorator_types.map(&:name) }
    
  def number
    questionnaire.pages.index(self) + 1
  end
    
  private
  def set_untitled
    if self.title.blank?
      self.title = "Untitled page"
    end
  end
end
