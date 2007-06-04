class EmailAddress < ActiveRecord::Base
  establish_connection :users
  belongs_to :account
  validates_uniqueness_of :address
  
  def primary=(value)
    if value and not account.nil?
      account.email_addresses.each do |addr|
        if addr != self
          addr.primary = false
          addr.save
        end
      end
    end
    write_attribute(:primary, value)
  end
end
