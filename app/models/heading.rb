class Heading < Question
  before_save do |field|
    if field.caption.blank?
      field.caption = "Click here to type."
    end
  end
end