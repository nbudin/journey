class Tag < ApplicationRecord
  has_many :taggings, :dependent => :destroy
  has_many :questionnaires, -> {where(taggings: {tagged_type: 'Questionnaire'})}, :through => :taggings, :source => :questionnaire

  validates_uniqueness_of "name"
end
