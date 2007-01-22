class Questionnaire < ActiveRecord::Base
  has_many :pages, :dependent => :destroy, :order => :position
  has_many :responses, :dependent => :destroy, :order => "id DESC"
  has_many :special_field_associations, :dependent => :destroy, :foreign_key => :questionnaire_id
  has_many :special_fields, :through => :special_field_associations, :source => :question
  has_many :questions, :through => :pages
  
  def Questionnaire.special_field_purposes
    %w( name address phone email gender )
  end
  
  def after_create
    page = Page.create :questionnaire_id => id
    page.insert_at(1)
  end

  def rss_secret
    if read_attribute(:rss_secret).nil?
      self.rss_secret = SHA1.sha1("#{self.id}_#{Time.now.to_s}").to_s[0..5]
      self.save
    end
    read_attribute(:rss_secret)
  end
  
  def special_field(purpose)
    assn = special_field_associations.find_by_purpose(purpose)
    assn.nil? ? nil : assn.question
  end
end
