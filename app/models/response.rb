class Response < ActiveRecord::Base
  belongs_to :questionnaire, -> {includes(:special_field_associations)}
  validates_associated :questionnaire
  has_many :answers, -> {includes(question: :question_options)}, :dependent => :destroy
  belongs_to :person
  scope :valid, -> { where("responses.id in (select response_id from answers)") }
  scope :no_answer_for, lambda { |question|
        where("responses.id not in (select response_id from answers where question_id = ?)", question.id)
  }

  def self.per_page
    20
  end

  def after_create
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

  def submitted_or_created_at
    submitted ? submitted_at : created_at
  end
end
