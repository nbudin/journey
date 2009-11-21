module ColorHelper
  def journey_colors
    [
      ["Red Pill", "8d0000"],
      ["La Red", "d03200"],
      ["Orange Zest", "ffd032"],
      ["Old Gold", "d0ba32"],
      ["Leroy Brown", "9a6a00"],
      ["Journey Green", "bad032"],
      ["Putting Green", "006a32"],
      ["Blue Pill", "00326a"],
      ["Blue Meany", "32bad0"],
      ["Indigo Montoya", "6a00d0"],
      ["Purple People Eater", "ba32d0"],
      ["Fresh Lavender", "d09ad0"],
      ["Basic Black", "000000"],
      ["Stealth Grey", "666666"]
    ]
  end
  
  def journey_color_select_options
    journey_colors.collect do |name, color|
      css = "color: ##{color}; font-weight: bold; "
      #(r, g, b) = [color[0..1], color[2..3], color[4..5]].collect {|i| i.hex}
      #value = [r, g, b].max
      #if value > 128
      #  css << "background-color: white;"
      #else
      #  css << "background-color: black;"
      #end
      content_tag(:option, name, :value => "##{color}", :style => css)
    end.join("\n")
  end
end
