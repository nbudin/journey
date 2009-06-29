class Questions::SelectorField < Questions::Field
  def options_for_select
    return question_options.collect { |o| [ o.option, o.option ] }
  end
  
  def is_numeric?
    question_options.all? do |o|
      o.effective_output_value =~ /^[+-]?\d*(\.[\d]+)?$/
    end
  end
  
  def min
    question_options.collect { |o| o.to_f }.min.floor
  end
  
  def max
    question_options.collect { |o| o.to_f }.max.ceil
  end
  
  def xmlcontent(xml)
    super
    xml.question_options do
      self.question_options.each do |o|
        xml.question_option do
          xml.option(o.option)
        end
      end
    end
    xml.default_answer(self.default_answer)
    xml.purpose(self.purpose)
  end
  
  def deepclone
    c = super
    self.question_options.each do |o|
      c.question_options.push(o.clone)
    end
    
    return c
  end
end
