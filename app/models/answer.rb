class Answer < ActiveRecord::Base
  belongs_to :response
  validates_associated :response
  belongs_to :question
  validates_associated :question
  
  def self.find_answer(resp, question)
    Answer.find(:first, :conditions => ["response_id = #{resp.id} AND question_id = #{question.id}"])
  end
  
  def self.value(args)
    if args[:answer]
      answer = args[:answer]
      question = answer.question
    else
      question = args[:question]
      answer = args[:response].answer_for_question(args[:question])
    end
    
    no_answer_msg = if question.kind_of?(CheckBoxField)
      "false"
    else
      ""
    end
    
    if answer.nil?
      return no_answer_msg
    else
      v = answer.value
      if v.nil? or v.length == 0
        return no_answer_msg
      else
        return v
      end
    end
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
