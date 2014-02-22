class Question < ActiveRecord::Base
  self.store_full_sti_class = true
  
  belongs_to :page
  has_one :questionnaire, :through => :page
  acts_as_list :scope => :page
  has_many :answers, :dependent => :destroy
  has_one :special_field_association, :dependent => :destroy, :autosave => true, :inverse_of => :question
  has_many :question_options, :dependent => :destroy, :order => "position", :foreign_key => 'question_id', :autosave => true
  
  LAYOUTS = {
    :left => "left",
    :top => "top"
  }
  
  validates_inclusion_of :layout, :in => LAYOUTS.values
  
  def self.decorator_types
    [ Questions::Label, 
      Questions::Divider, 
      Questions::Heading ]
  end

  def self.field_types
    [ Questions::TextField, 
      Questions::BigTextField, 
      Questions::RangeField,
      Questions::CheckBoxField,
      Questions::DropDownField,
      Questions::RadioField ]
  end
  
  def self.question_types
    return self.decorator_types + self.field_types
  end
  
  def self.question_class_from_name(name)
    real_name = name =~ /^Questions::/ ? name : "Questions::#{name}"
    question_types.select { |klass| klass.name == real_name }.first
  end
  
  def self.friendly_name
    self.name
  end
  
  def active_model_serializer
    QuestionSerializer
  end
  
  def is_numeric?
    false
  end
  
  def purpose
    special_field_association.try(:purpose)
  end
  
  def purpose=(new_purpose)
    return new_purpose if purpose == new_purpose
    
    new_purpose.tap do
      if new_purpose.blank?
        self.special_field_association = nil
      elsif self.special_field_association
        self.special_field_association.purpose = new_purpose
      else
        self.build_special_field_association(purpose: new_purpose)
      end
    end
  end
  
  def deepclone
    dup.tap do |c|
      question_options.each do |qo|
        c.question_options << QuestionOption.new(option: qo.option, position: qo.position, output_value: qo.output_value)
      end
      
      c.purpose = purpose
    end
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
