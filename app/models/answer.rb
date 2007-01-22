class Answer < ActiveRecord::Base
  belongs_to :response
  validates_associated :response
  belongs_to :question
  validates_associated :question
  
  def self.find_answer(resp, question)
    Answer.find(:first, :conditions => ["response_id = #{resp.id} AND question_id = #{question.id}"])
  end
end
