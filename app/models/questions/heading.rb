class Questions::Heading < Question
  def self.friendly_name
    "Heading"
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