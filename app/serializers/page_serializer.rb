class PageSerializer < ActiveModel::Serializer
  attributes :id, :title, :questionnaire_id, :position
  
  has_many :questions, embed: :ids, include: true
end
