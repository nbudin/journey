class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :tagged, :polymorphic => true
  belongs_to :questionnaire, :class_name => "Questionnaire", :foreign_key => "tagged_id"
end
