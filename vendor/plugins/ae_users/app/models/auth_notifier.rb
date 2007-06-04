class AuthNotifier < ActionMailer::Base
  default_url_options[:host] = request.host
  
  def account_activation(account, address=nil)
    if address.nil?
      address = account.primary_email_address
    elsif address.kind_of? EmailAddress
      address = address.address
    end
    
    @recipients = address
    @from = "accounts@#{smtp_settings[:domain]}"
    @subject = "Your account on #{smtp_settings[:domain]}"
    
    @body["name"] = account.person.name || "New User"
    @body["account"] = account
    @body["server_name"] = smtp_settings[:domain]
  end
  
  def generated_password(account, password, address=nil)
    if address.nil?
      address = account.primary_email_address
    elsif address.kind_of? EmailAddress
      address = address.address
    end
    
    @recipients = address
    @from = "accounts@#{smtp_settings[:domain]}"
    @subject = "Your password has been reset on #{smtp_settings[:domain]}"
    
    @body["name"] = account.person.name
    @body["account"] = account
    @body["server_name"] = smtp_settings[:domain]
    @body["password"] = password
  end
end
