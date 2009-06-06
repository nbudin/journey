class Question < ActiveRecord::Base
  self.store_full_sti_class = true
  
  belongs_to :page
  has_one :questionnaire, :through => :page
  acts_as_list :scope => :page_id
  has_many :answers, :dependent => :destroy
  has_one :special_field_association, :dependent => :destroy
  has_many :question_options, :dependent => :destroy, :order => "position", :foreign_key => 'question_id'
  
  Layouts = {
    :left => "left",
    :top => "top"
  }
  
  validates_inclusion_of :layout, :in => Layouts.values
  
  def self.friendly_name
    self.name
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
end
