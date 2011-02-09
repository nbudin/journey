class Questions::RadioField < Questions::SelectorField
  def self.friendly_name
    "Radio buttons"
  end
  
  unless column_names.include?("radio_layout")
    class_eval <<-END
    def radio_layout
      "inline"
    end
    END
  end
  
  def radio_layout_class
    "layout-#{radio_layout}"
  end
end