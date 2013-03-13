class Person < ActiveRecord::Base
  devise :cas_authenticatable, :trackable

  def name
    "#{firstname} #{lastname}"
  end

  def cas_extra_attributes=(extra_attributes)
    extra_attributes.each do |name, value|
      case name.to_sym
      when :firstname
        self.firstname = value
      when :lastname
        self.lastname = value
      when :birthdate
        self.birthdate = value
      when :gender
        self.gender = value
      when :email
        self.email = value
      end
    end
  end
end