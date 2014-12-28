require 'journey_questionnaire'

class Page < ActiveRecord::Base
  belongs_to :questionnaire
  has_many :questions, -> { order(:position).includes(:page, :question_options, :special_field_association) }, :dependent => :destroy
  has_many :fields, -> { where(type: Question.field_types.map(&:name)).order(:position) }, :class_name => 'Question'
  has_many :decorators, -> { order(:position).where(type: Question.decorator_types.map(&:name)) }, :class_name => 'Question'
    
  before_create :set_untitled
  before_create :set_position
    
  def number
    questionnaire.pages.index(self) + 1
  end
  
  private
  def set_untitled
    if self.title.blank?
      self.title = "Untitled page"
    end
  end
  
  def set_position
    return if position
    self.position = (questionnaire.pages.maximum(:position) || 0) + 1
  end
end
