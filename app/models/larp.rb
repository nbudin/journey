class Larp < ActiveRecord::Base
  has_many :runs, :class_name => "LarpRun"
end
