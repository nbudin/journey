class SelectorField < Field
  has_many :question_options, :dependent => :destroy, :foreign_key => 'question_id'
  
  def options_for_select
    return question_options.collect { |o| [ o.option, o.option ] }
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