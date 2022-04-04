class QuestionOption < ApplicationRecord
  belongs_to :question
  before_create :set_position

  def effective_output_value
    if output_value.blank?
      option
    else
      output_value
    end
  end

  private
  def set_position
    return if position
    self.position = (question.question_options.maximum(:position) || 0) + 1
  end
end
