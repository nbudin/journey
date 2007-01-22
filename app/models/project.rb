class Project < ActiveRecord::Base
  validates_presence_of :name, :repo_url
  validates_presence_of :password, :if => Proc.new { |project| project.username and project.username.length > 0 }
  has_many :checkouts, :dependent => :destroy
end
