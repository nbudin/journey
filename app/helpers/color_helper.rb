module ColorHelper
  def journey_colors
    [
      ["Red Adair", "8d0000"],
      ["La Red", "d03200"],
      ["Orange Zest", "ffd032"],
      ["Old Gold", "d0ba32"],
      ["Doc Brown", "9a6a00"],
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
    color_options = journey_colors.collect do |name, color|
      css = "color: ##{color}; font-weight: bold; "
      content_tag(:option, name, :value => "##{color}", :style => css)
    end
    safe_join color_options, "\n"
  end
end
