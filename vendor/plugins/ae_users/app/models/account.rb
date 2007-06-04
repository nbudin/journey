require 'digest/md5'

class Account < ActiveRecord::Base
  establish_connection :users
  has_one :person
  has_many :email_addresses, :dependent => :destroy
  
  def self.find_by_email_address(address)
    ea = EmailAddress.find_by_address(address)
    if not ea.nil?
      return ea.account
    end
  end
  
  def primary_email_address
    primary = email_addresses.find_by_primary true
    if not primary
      primary = email_addresses.find :first
    end
    if primary.nil?
      return nil
    else
      return primary.address
    end
  end
  
  def password=(password)
    if not password.nil?
      write_attribute("password", Account.hash_password(password))
    else
      write_attribute("password", nil)
    end
  end
  
  def self.hash_password(password)
    return Digest::MD5.hexdigest(password)
  end
  
  def check_password(password)
    return self.password == Account.hash_password(password)
  end
  
  def generate_password(address = nil, length = 6)
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('1'..'9').to_a - ['o', 'O', 'i', 'I']
    genpwd = Array.new(length) { chars[rand(chars.size)] }.join
    self.password= genpwd
    save
    AuthNotifier::deliver_generated_password(self, genpwd, address)
    return genpwd
  end
  
  def generate_activation(address=nil)
    self.active = false
    self.activation_key = Digest::MD5.hexdigest("#{password} #{Time.now.to_s}")
    self.save
    
    AuthNotifier::deliver_account_activation(self, address)
  end
end
