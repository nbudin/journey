class PageSerializer < ActiveModel::Serializer
  attributes :id, :title, :questionnaire_id
  
  has_many :questions, embed: :ids
end
