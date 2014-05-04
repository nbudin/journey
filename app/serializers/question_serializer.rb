class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :type, :caption, :page_id, :position, :layout, :radio_layout, :required, :default_answer, :min, :max, :step
  
  has_many :question_options, embed: :ids, include: true
end
