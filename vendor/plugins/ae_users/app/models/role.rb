class Role < ActiveRecord::Base
  establish_connection :users
  has_and_belongs_to_many :people
  has_many :permissions
end
