class LarpRun < ActiveRecord::Base
  belongs_to :larp
  has_and_belongs_to_many :players, :class_name => "User", :join_table => "players"
end
