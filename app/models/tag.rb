class Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy
  has_many :questionnaires, :through => :taggings, :source => :questionnaire,
    :conditions => "taggings.tagged_type = 'Questionnaire'"
  
  validates_uniqueness_of "name"
end
