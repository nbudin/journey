class Question < ActiveRecord::Base
  self.store_full_sti_class = true
  
  belongs_to :page
  has_one :questionnaire, :through => :page
  acts_as_list :scope => :page_id
  has_many :answers, :dependent => :destroy
  has_one :special_field_association, :dependent => :destroy
  has_many :question_options, :dependent => :destroy, :order => "position", :foreign_key => 'question_id'
  
  accepts_nested_attributes_for :question_options, :allow_destroy => true
  
  Layouts = {
    :left => "left",
    :top => "top"
  }
  
  validates_inclusion_of :layout, :in => Layouts.values
  
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
  
  def self.types_for_sql(types)
    '(' + types.collect { |klass| "'#{klass.name}'" }.join(', ') + ')'
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
  
  def is_numeric?
    false
  end
  
  def deepclone
    c = self.class.new
    c.page = self.page
    c.caption = self.caption
    c.required = self.required
    c.layout = self.layout
    
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
  
  # we want to always use Question as the DOM class name
  def self.model_name
    @model_name ||= ::ActiveSupport::ModelName.new("Question")
  end
end
