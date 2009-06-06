class Questions::DropDownField < Questions::SelectorField
  def self.friendly_name
    "Drop-down menu"
  end
  
  def options_for_select
    return [['', '']] + super
  end
end