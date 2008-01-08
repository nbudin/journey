class Question < ActiveRecord::Base
  belongs_to :page
  acts_as_list :scope => :page_id
  has_many :answers, :dependent => :destroy
  
  def questionnaire
    page.questionnaire
  end
  
  def deepclone
    c = self.class.new
    c.page = self.page
    c.caption = self.caption
    c.required = self.required
    
    return c
  end
  
  def xmlcontent(xml)
    xml.page_id(self.page.id)
    xml.caption(self.caption)
    xml.required(self.required)
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.question do
      xmlcontent(xml)
    end
  end
end

class Label < Question
  validates_presence_of :caption
end

class Divider < Question
end

class Heading < Question
  validates_presence_of :caption
end

class Field < Question
  has_one :special_field_association, :foreign_key => :question_id
  
  def purpose
    if special_field_association.nil?
      nil
    else
      special_field_association.purpose
    end
  end
  
  def purpose=(newpurpose)
    if not (newpurpose.nil? or newpurpose == '')
      if special_field_association.nil?
        sfa = SpecialFieldAssociation.create!(:questionnaire => questionnaire,
                                              :purpose => newpurpose,
                                              :question => self)
        reload
      else
        special_field_association.purpose = newpurpose
      end
    else
      if not special_field_association.nil?
        special_field_association.destroy
      end
    end
  end
  
  before_save do |field|
    if not field.special_field_association.nil?
      field.special_field_association.save!
    end
  end
  
  def to_json
    #awful hack to get purpose into the attributes list
    json = super
    return json.sub(/(attributes: \{)/, "\\1'purpose': #{purpose.to_json}, ")
  end
  
  def xmlcontent(xml)
    super
    xml.default_answer(self.default_answer)
    xml.purpose(self.purpose)
  end
  
  def deepclone
    c = super
    c.default_answer = self.default_answer
    
    return c
  end
end

class FreeformField < Field
end

class TextField < FreeformField
end

class BigTextField < FreeformField
end

class CheckBoxField < Field
end

class RangeField < Field
  validates_presence_of :min, :max, :step
  validates_numericality_of :min, :max, :step, :integer => true
  validates_exclusion_of :step, :in => [0]
  
  validate :range_boundaries
  def range_boundaries
    if step > 0
      if min > max
        errors.add('min', 'cannot be greater than max if step is positive')
      end
    else
      if min < max
        errors.add('min', 'cannot be less than max if step is negative')
      end
    end
  end
  
  def xmlcontent(xml)
    super
    xml.min(self.min)
    xml.max(self.max)
    xml.step(self.step)
  end
  
  def deepclone
    c = super
    c.min = self.min
    c.max = self.max
    c.step = self.step
    
    return c
  end
end

class SelectorField < Field
  has_many :question_options, :dependent => :destroy, :foreign_key => 'question_id'
  
  def options_for_select
    return question_options.collect { |o| [ o.option, o.option ] }
  end
  
  def xmlcontent(xml)
    super
    xml.question_options do
      self.question_options.each do |o|
        xml.question_option do
          xml.option(o.option)
        end
      end
    end
    xml.default_answer(self.default_answer)
    xml.purpose(self.purpose)
  end
  
  def deepclone
    c = super
    self.question_options.each do |o|
      c.question_options.push(o.clone)
    end
    
    return c
  end
end

class DropDownField < SelectorField
  def options_for_select
    return [['', '']] + super
  end
end

class RadioField < SelectorField
end