class Questionnaire < ActiveRecord::Base
  acts_as_permissioned :permission_names => [:edit, :export, :view_answers, :edit_answers]

  has_many :pages, :dependent => :destroy, :order => :position
  has_many :responses, :dependent => :destroy, :order => "id DESC"
  has_many :special_field_associations, :dependent => :destroy, :foreign_key => :questionnaire_id
  has_many :special_fields, :through => :special_field_associations, :source => :question
  has_many :questions, :through => :pages
  has_many :fields, :through => :pages, :class_name => 'Question', :order => :position,
    :conditions => "type in #{Journey::Questionnaire::types_for_sql(Journey::Questionnaire::field_types)}"
  has_many :decorators, :through => :pages, :class_name => 'Question', :order => :position,
    :conditions => "type in #{Journey::Questionnaire::types_for_sql(Journey::Questionnaire::decorator_types)}"

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

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]

    xml.questionnaire(:title => title) do
      if custom_html
        xml.custom_html(custom_html)
      end
      if custom_css
        xml.custom_css(custom_css)
      end
      pages.each do |page|
        xml.page(:title => page.title) do
          page.questions.each do |question|
            xml.question(:type => question.class.to_s, :required => question.required) do
              xml.caption(question.caption)
              xml.default_answer(question.default_answer)
              if question.kind_of? RangeField
                xml.range(:min => question.min, :max => question.max, :step => question.step)
              end
              if question.kind_of? SelectorField
                question.question_options.each do |option|
                  xml.option(option.option)
                end
              end
            end
          end
        end
      end
    end
  end
end
