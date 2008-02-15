require 'sha1'
require 'rexml/document'

class Questionnaire < ActiveRecord::Base
  acts_as_permissioned :permission_names => [:edit, :view_answers, :edit_answers, :destroy]

  has_many :pages, :dependent => :destroy, :order => :position
  has_many :responses, :dependent => :destroy, :order => "id DESC"
  has_many :valid_responses, :order => "id DESC", :class_name => "Response",
    :conditions => "id in (select response_id from answers)"
  has_many :special_field_associations, :dependent => :destroy, :foreign_key => :questionnaire_id
  has_many :special_fields, :through => :special_field_associations, :source => :question
  has_many :questions, :through => :pages, :order => "pages.position, questions.position"
  has_many :fields, :through => :pages, :class_name => 'Question', :order => "pages.position, questions.position",
    :conditions => "type in #{Journey::Questionnaire::types_for_sql(Journey::Questionnaire::field_types)}"
  has_many :decorators, :through => :pages, :class_name => 'Question', :order => "pages.position, questions.position",
    :conditions => "type in #{Journey::Questionnaire::types_for_sql(Journey::Questionnaire::decorator_types)}"

  def Questionnaire.special_field_purposes
    %w( name address phone email gender )
  end
  
  def used_special_field_purposes
    special_field_associations.collect { |sfa| sfa.purpose }
  end
  
  def unused_special_field_purposes
    usfp = used_special_field_purposes
    Questionnaire.special_field_purposes.select { |p| not usfp.include?(p) }
  end

  def after_create
    if pages.length == 0
      page = Page.create :questionnaire_id => id, :title => "Untitled page"
      page.insert_at(1)
    end
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
  
  def Questionnaire.from_xml(xml)
    root = REXML::Document.new(xml).root
    q = Questionnaire.new(:title => root.attributes['title'], :custom_html => '',
      :custom_css => '', :is_open => false)
    root.each_element do |element|
      if element.name == 'custom_html'
        q.custom_html = element.text
      elsif element.name == 'custom_css'
        q.custom_css = element.text
      elsif element.name == 'page'
        p = q.pages.new :title => element.attributes['title']
        element.each_element do |question|
          if question.name != 'question'
            raise "Found a #{question.name} tag that shouldn't be a direct child of page"
          end
          
          if not Journey::Questionnaire::question_types.include?(question.attributes['type'])
            raise "#{question.attributes['type']} is not a valid question type"
          end
          
          klass = Journey::Questionnaire::question_class(question.attributes['type'])
          ques = klass.new(:required => question.attributes['required'], :page => p)
          
          ques.caption = ""
          question.each_element('caption') do |caption|
            ques.caption = caption.text
            if ques.caption.nil?
              ques.caption = ""
            end
          end
          da = nil
          question.each_element('default_answer') do |default_answer|
            da = default_answer.text
            logger.info "Default answer is #{da}"
          end
          
          if ques.kind_of? RangeField
            question.each_element('range') do |range|
              ['min', 'max', 'step'].each do |attrib|
                ques.send "#{attrib}=", range.attributes[attrib]
              end
            end
          end
          
          if ques.kind_of? SelectorField
            optrows = {}
            question.each_element('option') do |option|
              o = QuestionOption.new :option => option.text
              ques.question_options << o
              optrows[option.text] = o
              logger.info("Inserted optrows[#{option.text}] with id #{o.id}")
            end
            if da and da.length > 0
              optrow = optrows[da]
              if optrow.nil?
                logger.warn("No optrow called #{da} found!")
              else
                logger.info("Setting default answer for question to #{optrows[da].option}")
                ques.default_answer = optrows[da].option
              end
            end
          end
          
          ques.position = p.questions.length + 1
          p.questions << ques
        end
        
        p.position = q.pages.length + 1
        q.pages << p
      else
        raise "Found a #{element.name} tag that shouldn't be a direct child of questionnaire"
      end
    end
    return q
  end
end
