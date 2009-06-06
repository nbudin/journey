class Questions::RangeField < Questions::Field
  validates_presence_of :min, :max, :step
  validates_numericality_of :min, :max, :step, :integer => true
  validates_exclusion_of :step, :in => [0]
  
  def self.friendly_name
    "Numeric range"
  end
  
  validate :range_boundaries
  def range_boundaries
    if step > 0
      if min > max
        errors.add('min', 'cannot be greater than max if step is positive')
      end
    else
      if min < max
        errors.add('min', 'cannot be less than max if step is negative')
      end
    end
  end
  
  def xmlcontent(xml)
    super
    xml.min(self.min)
    xml.max(self.max)
    xml.step(self.step)
  end
  
  def deepclone
    c = super
    c.min = self.min
    c.max = self.max
    c.step = self.step
    
    return c
  end
end