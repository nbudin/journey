class QuestionnaireSerializer < ActiveModel::Serializer
  attributes :id
  
  has_many :pages, embed: :ids
end
