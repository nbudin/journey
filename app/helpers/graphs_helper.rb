module GraphsHelper
  def set_journey_theme(graph)
    graph.theme = {
      :colors => %w{#bad032 #5ba5ff #ff7474 #00d686 #8d0081 #ff9500 #512f00},
      :marker_color => 'black',
      :background_colors => ['white', 'white']
      }
  end
end
