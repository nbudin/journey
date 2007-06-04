class Person < ActiveRecord::Base
  establish_connection :users
  belongs_to :account
  has_and_belongs_to_many :roles
  has_many :attendances
  has_many :events, :through => :attendances
  
  def permitted?(object, permission)
    roles.each do |role|
      role.permissions.each do |permission|
        if ((permission.object.nil? or permission.object == object) and 
          (permission.permission.nil? or permission.permission == permission))
          return true
        end
      end
    end
    
    return false
  end
  
  def ignore_events_cond(ignore_events)
    if ignore_events.length > 0
      return "AND events.id NOT IN ("+ignore_events.collect { |e| e.id }.join(',') + ")"
    else
      return ""
    end
  end
  
  def busy_at?(time, ignore_events=[])
    return events.count(:all, 
      :conditions => ["start <= ? AND end > ? #{ignore_events_cond ignore_events}", time, time]) > 0
  end
  
  def busy_between?(start_time, end_time, ignore_events=[])
    return (busy_at?(start_time, ignore_events) or 
      events.count(:all, :conditions => ["(end > ? AND start <= ?) #{ignore_events_cond ignore_events}", 
        start_time, end_time]) > 0)
  end
  
  def name
    n = firstname
    if nickname and nickname.length > 0
      n += " \"#{nickname}\""
    end
    n += " #{lastname}"
    return n
  end
  
  def current_age
    age_as_of Date.today
  end
  
  def age_as_of(base = Date.today)
    if not birthdate.nil?
      base.year - birthdate.year - ((base.month * 100 + base.day >= birthdate.month * 100 + birthdate.day) ? 0 : 1)
    end
  end
end
