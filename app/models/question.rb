class Question < ActiveRecord::Base
  belongs_to :page
  acts_as_list :scope => :page_id
  has_many :answers, :dependent => :destroy
  
  Layouts = {
    :left => "left",
    :top => "top"
  }
  
  validates_inclusion_of :layout, :in => Layouts.values
  
  def questionnaire
    page.questionnaire
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
