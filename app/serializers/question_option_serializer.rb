class QuestionOptionSerializer < ActiveModel::Serializer
  attributes :id, :option, :output_value, :question_id, :position
end
