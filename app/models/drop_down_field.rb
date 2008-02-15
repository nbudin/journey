class DropDownField < SelectorField
  def options_for_select
    return [['', '']] + super
  end
end