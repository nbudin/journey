class Response < ActiveRecord::Base
  belongs_to :questionnaire, :include => [:special_field_associations, :fields]
  validates_associated :questionnaire
  has_many :answers, :dependent => :destroy, :include => {:question => :question_options}
  belongs_to :person
  named_scope :valid, :conditions => "responses.id in (select response_id from answers)"
  named_scope :no_answer_for, lambda { |question|
        { :conditions => ["responses.id not in (select response_id from answers where question_id = ?)", question.id] }
  }
  
  def self.per_page
    20
  end
  
  def after_create
  end
  
  def verify_answers_for_page(page)
    page.questions.each do |question|
      if question.kind_of? Field
        if not self.answers.find_by_question_id(question.id)
          a = Answer.new
          a.response = self
          a.question = question
          if question.default_answer
            a.value = question.default_answer
          end
          a.save!
        end
      end
    end
  end
  
  def verify_answers
    self.questionnaire.pages.each do |page|
      verify_answers_for_page(page)
    end
  end
  
  def answer_for_question(question)
    answers.select { |a| a.question == question }[0]
  end
  
  def special_answer(purpose)
    spfield = questionnaire.special_field(purpose)
    spfield.nil? ? nil : answer_for_question(spfield)
  end
  
  def special_answers
    questionnaire.special_field_associations.collect do |sfa|
      answer_for_question sfa.question
    end.compact
  end
  
  def title
    name_answer = special_answer('name')
    if name_answer.nil? or name_answer.value.blank?
      "Response ID\##{id}"
    else
      name = name_answer.value
      if (not name.nil?) and name.length > 0
        name
      else
        "No name"
      end
    end
  end
  
  def submitted_at
    if submitted
      answers.collect { |answer| answer.updated_at }.max.strftime("%Y-%m-%d %I:%M %p")
    else
      nil
    end
  end
end
