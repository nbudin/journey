require 'journey_questionnaire'

class Page < ActiveRecord::Base
  belongs_to :questionnaire
  acts_as_list :scope => :questionnaire_id
  has_many :questions, :order => :position, :dependent => :destroy, :include => [:page, :question_options, :special_field_association]
  has_many :fields, :class_name => 'Question', :order => :position,
    :conditions => "type in #{Journey::Questionnaire::types_for_sql(Journey::Questionnaire::field_types)}"
  has_many :decorators, :class_name => 'Question', :order => :position,
    :conditions => "type in #{Journey::Questionnaire::types_for_sql(Journey::Questionnaire::decorator_types)}"
end
