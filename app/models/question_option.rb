class QuestionOption < ActiveRecord::Base
  belongs_to :question
  acts_as_list :scope => :question
end
