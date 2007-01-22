class Player < ActiveRecord::Base
  belongs_to :run, :class_name => :LarpRun
  belongs_to :user
end
