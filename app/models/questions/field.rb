class Questions::Field < Question
  has_one :special_field_association, :foreign_key => :question_id
  
  def to_json
    super :methods => "purpose"
  end
  
  def xmlcontent(xml)
    super
    xml.default_answer(self.default_answer)
    xml.purpose(self.purpose)
  end
  
  def deepclone
    c = super
    c.default_answer = self.default_answer
    
    return c
  end
end