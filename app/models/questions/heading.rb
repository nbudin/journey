class Questions::Heading < Question
  def caption
    cap = read_attribute :caption
    if cap.blank?
      "Click here to type."
    else
      cap
    end
  end
end