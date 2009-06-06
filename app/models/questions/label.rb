class Questions::Label < Question
  def self.friendly_name
    "Display text"
  end
  
  def caption
    cap = read_attribute :caption
    if cap.blank?
      "Click here to type."
    else
      cap
    end
  end
end