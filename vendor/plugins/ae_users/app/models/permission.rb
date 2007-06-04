class Permission < ActiveRecord::Base
  establish_connection :users
  belongs_to :role
  belongs_to :permissioned, :polymorphic => true
  
  def object
    return permissioned
  end
end
