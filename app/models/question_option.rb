class QuestionOption < ActiveRecord::Base
  belongs_to :question
    
  def effective_output_value
    if output_value.blank?
      option
    else
      output_value
    end
  end
end
