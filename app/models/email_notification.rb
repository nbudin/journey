class EmailNotification < ActiveRecord::Base
  attr_accessible :notify_on_response_start, :notify_on_response_submit
  
  belongs_to :questionnaire
  belongs_to :person
  
  scope :notify_on_response_start, -> { where(notify_on_response_start: true) }
  scope :notify_on_response_submit, -> { where(notify_on_response_submit: true) }
end
