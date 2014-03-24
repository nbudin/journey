class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :type, :caption, :page_id, :position, :layout, :required
end
