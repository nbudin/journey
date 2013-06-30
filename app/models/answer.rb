class Answer < ActiveRecord::Base
  belongs_to :response
  validates_associated :response
  belongs_to :question
  validates_associated :question
  
  def self.find_answer(resp, question)
    where(response_id: resp.id, question_id: question.id).first
  end
  
  def value
    v = read_attribute(:value)
    if question.kind_of?(Questions::CheckBoxField)
      if v
        return "true"
      else
        return "false"
      end
    else
      return v
    end
  end
  
  def output_value
    v = self.value
    if question.kind_of?(Questions::SelectorField)
      opt = question.question_options.select {|qo| qo.option == v }.first
      if opt.nil?
        return v
      end
      if opt.output_value and opt.output_value != ''
        v = opt.output_value
      end
    end
    return v
  end
end
