class NotificationMailer < ActionMailer::Base
  include SendGrid
  layout "email"
  
  default from: "Journey Surveys <journey@sugarpond.net>"
  sendgrid_enable :subscriptiontrack
  sendgrid_subscriptiontrack_text replace: "[sendgrid_unsubscribe_url]"
  
  def response_started(resp, recipient)
    @resp = resp
    @recipient = recipient
    
    mail(to: @recipient.email, subject: "[#{resp.questionnaire.title}] New response started")
  end
  
  def response_submitted(resp, recipient)
    @resp = resp
    @recipient = recipient
    
    mail(to: @recipient.email, subject: "[#{resp.questionnaire.title}] New response submitted")
  end
end
