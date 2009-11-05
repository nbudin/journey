module ColorHelper
  def journey_colors
    [
      ["Dracula Red", "8d0000"],
      ["Red Pill", "d03200"],
      ["Orange Zest", "ffd032"],
      ["Old Gold", "d0ba32"],
      ["Journey Green", "bad032"],
      ["Forest Green", "006a32"],
      ["Sea Blue", "00326a"],
      ["Sky Blue", "32bad0"],
      ["Indigo Montoya", "6a00d0"],
      ["Shocking Violet", "ba32d0"],
      ["Fresh Lavender", "d0bad0"]
    ]
  end
  
  def journey_color_select_options
    journey_colors.collect do |name, color|
      css = "background-color: ##{color}; font-weight: bold; "
      (r, g, b) = [color[0..1], color[2..3], color[4..5]].collect {|i| i.hex}
      value = [r, g, b].max
      if value < 128
        css << "color: white;"
      else
        css << "color: black;"
      end
      content_tag(:option, name, :value => "##{color}", :style => css)
    end.join("\n")
  end
end
