class Questions::Field < Question
  # inverse_of is needed so the association built by purpose= can find its question (and so its questionnaire)
  has_one :special_field_association, :foreign_key => :question_id, :inverse_of => :question
  
  def to_json
    super :methods => "purpose"
  end
  
  def xmlcontent(xml)
    super
    xml.default_answer(self.default_answer)
    xml.purpose(self.purpose)
  end
end