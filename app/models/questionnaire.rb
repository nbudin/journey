require 'digest'
require 'rexml/document'
require 'journey_questionnaire'

class Questionnaire < ActiveRecord::Base
  acts_as_permissioned :permission_names => [:edit, :view_answers, :edit_answers, :destroy]
  
  before_create :set_untitled
  after_create :create_initial_page

  has_many :pages, :dependent => :destroy, :order => :position
  has_many :responses, :dependent => :destroy, :order => "responses.id DESC", :include => [:answers, :questionnaire]
  has_many :valid_responses, :order => "responses.id DESC", :class_name => "Response",
    :conditions => "responses.id in (select response_id from answers)", :include => [:answers, :questionnaire]
  has_many :special_field_associations, :dependent => :destroy, :foreign_key => :questionnaire_id
  has_many :special_fields, :through => :special_field_associations, :source => :question
  has_many :questions, :through => :pages, :order => "pages.position, questions.position"
  has_many :fields, :through => :pages, :class_name => 'Question', :order => "pages.position, questions.position",
    :conditions => "type in #{Question.types_for_sql(Question.field_types)}", :include => :page
  has_many :decorators, :through => :pages, :class_name => 'Question', :order => "pages.position, questions.position",
    :conditions => "type in #{Question.types_for_sql(Question.decorator_types)}", :include => :page
  has_many :taggings, :as => :tagged, :dependent => :destroy
  has_many :tags, :through => :taggings
  
  named_scope :publicly_visible, :conditions => { :publicly_visible => true }
  
  def Questionnaire.special_field_purposes
    %w( name address phone email gender )
  end

  def Questionnaire.special_field_type(purpose)
    if %w( address ).include?(purpose)
      Questions::BigTextField
    elsif %( gender ).include?(purpose)
      Questions::RadioField
    else
      Questions::TextField
    end
  end
  
  @@creator_warning_hooks = []
  def Questionnaire.creator_warnings(person)
    @@creator_warning_hooks.collect do |hook|
      hook.call(person)
    end.compact
  end
  
  def Questionnaire.add_creator_warning_hook(hook)
    @@creator_warning_hooks.push(hook)
  end

  def used_special_field_purposes
    special_field_associations.collect { |sfa| sfa.purpose }
  end
  
  def unused_special_field_purposes
    usfp = used_special_field_purposes
    Questionnaire.special_field_purposes.select { |p| not usfp.include?(p) }
  end

  def rss_secret
    if read_attribute(:rss_secret).nil?
      self.rss_secret = Digest::SHA1.hexdigest("#{self.id}_#{Time.now.to_s}")[0..5]
      self.save
    end
    read_attribute(:rss_secret)
  end

  def special_field(purpose)
    assn = special_field_associations.select { |sfa| sfa.purpose == purpose }[0]
    assn.nil? ? nil : assn.question
  end
  
  def tag_names
    tags.collect {|t| t.name}
  end
  
  def tags=(taglist)
    names = taglist.split(/\s*,\s*/)
    names.each do |name|
      if not tags.find_by_name(name)
        t = Tag.find_or_create_by_name(name)
        taggings.create :tag => t
      end
    end
    taggings.each do |tagging|
      if not names.include?(tagging.tag.name)
        tagging.destroy
      end
    end
  end
  
  def login_policy
    if advertise_login
      if require_login
        return "required"
      else
        return "prompt"
      end
    else
      return "unadvertised"
    end
  end
  
  def login_policy=(policy)
    case policy.to_s
    when "unadvertised"
      self.advertise_login = false
      self.require_login = false
    when "prompt"
      self.advertise_login = true
      self.require_login = false
    when "required"
      self.advertise_login = true
      self.require_login = true
    end
  end
  
  def publication_mode
    if is_open
      if publicly_visible
        return "publicly_visible"
      else
        return "hidden"
      end
    else
      return "unpublished"
    end
  end
  
  def publication_mode=(mode)
    case mode.to_s
    when "unpublished"
      self.is_open = false
      self.publicly_visible = false
    when "hidden"
      self.is_open = true
      self.publicly_visible = false
    when "publicly_visible"
      self.is_open = true
      self.publicly_visible = false
    end
  end
    

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]

    xml.questionnaire(:title => title) do
      if taggings.size > 0
        xml.tags do
          tag_names.each do |name|
            xml.tag(:name => name)
          end
        end
      end
      if custom_html
        xml.custom_html(custom_html)
      end
      if custom_css
        xml.custom_css(custom_css)
      end
      if welcome_text
        xml.welcome_text(welcome_text)
      end
      pages.each do |page|
        xml.page(:title => page.title) do
          page.questions.each do |question|
            xml.question(:type => question.class.to_s, :required => question.required) do
              xml.caption(question.caption)
              xml.default_answer(question.default_answer)
              if question.kind_of? Questions::Field
                if question.purpose
                  xml.purpose(question.purpose)
                end
              end
              if question.kind_of? Questions::RangeField
                xml.range(:min => question.min, :max => question.max, :step => question.step)
              end
              if question.kind_of? Questions::SelectorField
                question.question_options.each do |option|
                  xml.option(option.option, :output_value => option.output_value)
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
      elsif element.name == 'welcome_text'
        q.welcome_text = element.text
      elsif element.name == 'tags'
        element.each_element("tag") do |tag|
          t = Tag.find_or_create_by_name(tag.attributes['name'])
          tagging = q.taggings.new :tag => t
          q.taggings << tagging
        end
      elsif element.name == 'page'
        p = q.pages.new :title => element.attributes['title']
        element.each_element do |question|
          if question.name != 'question'
            raise "Found a #{question.name} tag that shouldn't be a direct child of page"
          end
          
          klass = Question.question_class_from_name(question.attributes['type'])
          unless klass
            raise "#{question.attributes['type']} is not a valid question type"
          end

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
          
          question.each_element('purpose') do |purpose|
            sfa = q.special_field_associations.new :question => ques, :purpose => purpose.text
            q.special_field_associations << sfa
          end
          
          if ques.kind_of? Questions::RangeField
            question.each_element('range') do |range|
              ['min', 'max', 'step'].each do |attrib|
                ques.send "#{attrib}=", range.attributes[attrib]
              end
            end
          end
          
          if ques.kind_of? Questions::SelectorField
            optrows = {}
            question.each_element('option') do |option|
              o = QuestionOption.new :option => option.text
              if option.attributes["output_value"]
                o.output_value = option.attributes["output_value"]
              end
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
  
  def self.load_extensions
    Journey::QuestionnaireExtensions.extensions.each do |ext|
      include ext
    end
  end
  self.load_extensions
  
  private
  def set_untitled
    if self.title.blank?
      self.title = "Untitled survey"
    end
  end
  
  def create_initial_page
    if pages.size == 0
      pages.create
    end
  end
end
