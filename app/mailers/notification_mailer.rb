class NotificationMailer < ActionMailer::Base
  layout "email"
  
  default from: "Journey Surveys <journey@sugarpond.net>"
  
  def response_submitted(resp, recipient)
    @resp = resp
    @recipient = recipient
    
    mail(to: @recipient.email, subject: "[#{resp.questionnaire.title}] New response submitted")
  end
end
