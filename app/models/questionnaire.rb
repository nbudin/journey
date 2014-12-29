require 'digest'
require 'rexml/document'
require 'journey_questionnaire'

class Questionnaire < ActiveRecord::Base
  before_create :set_untitled
  after_create :create_initial_page
  before_save :set_published_at
  before_save :set_closed_at

  has_many :pages, -> {order(:position)},  :dependent => :destroy, :inverse_of => :questionnaire
  has_many :responses, -> {order(id: :desc).includes(:answers, :questionnaire)}, :dependent => :destroy, :inverse_of => :questionnaire
  has_many :valid_responses, -> {
    order(id: :desc).where(responses: {id: Answer.select(:response_id)}).includes(:answers, :questionnaire)
  }, :class_name => "Response"
  has_many :valid_responses_for_export, -> {
    order(id: :desc).where(responses: {id: Answer.select(:response_id)})
  }, :class_name => "Response"
  has_many :submitted_responses, -> {order(id: :desc).where.not(submitted_at: nil)}, :class_name => "Response"
  has_many :special_field_associations, :dependent => :destroy, :foreign_key => :questionnaire_id, :inverse_of => :questionnaire
  has_many :special_fields, :through => :special_field_associations, :source => :question
  has_many :questions, -> {reorder("pages.position, questions.position") }, :through => :pages
  has_many :fields, -> {reorder("pages.position, questions.position") }, :through => :pages
  has_many :decorators, -> {reorder("pages.position, questions.position") }, :through => :pages
  has_many :taggings, :as => :tagged, :dependent => :destroy
  has_many :tags, :through => :taggings
  has_many :email_notifications
  
  has_many :questionnaire_permissions
  accepts_nested_attributes_for :questionnaire_permissions, :allow_destroy => true, :reject_if => lambda { |attrs| attrs['id'].blank? && attrs['email'].blank? }
  
  scope :publicly_visible, lambda { where(:publicly_visible => true) }
  
  def Questionnaire.special_field_purposes
    %w( name address phone email gender )
  end

  def Questionnaire.special_field_type(purpose)
    if %w( address ).include?(purpose)
      Questions::BigTextField
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
      if not tags.find_by(name: name)
        t = Tag.find_or_create_by(name: name)
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
      if published_at
        return "closed"
      else
        return "unpublished"
      end
    end
  end
  
  def publication_mode=(mode)
    case mode.to_s
    when "unpublished", "closed"
      self.is_open = false
      self.publicly_visible = false
    when "hidden"
      self.is_open = true
      self.publicly_visible = false
    when "publicly_visible"
      self.is_open = true
      self.publicly_visible = true
    end
  end
  
  def deepclone(with_responses=nil)
    dup.tap do |c|
      question_clones_by_original_id = {}
      
      pages.each do |page|
        page_clone = page.dup.tap do |page_clone|
          page.questions.each do |question|
            question_clone = question.deepclone
            question_clones_by_original_id[question.id] = question_clone
            page_clone.questions << question_clone
          end
        end
        c.pages << page_clone
      end
      
      taggings.each do |tagging|
        c.taggings << Tagging.new(tag: tagging.tag)
      end
      
      if with_responses
        responses.each do |response|
          c.responses << response.dup.tap do |response_clone|
            response.answers.each do |answer|
              answer_clone = answer.dup
              answer_clone.question = question_clones_by_original_id[answer.question_id]
              response_clone.answers << answer_clone
            end
          end
        end
      end
    end
  end

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= ::Builder::XmlMarkup.new(:indent => options[:indent])
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
              xml.layout(question.layout)
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
              if question.kind_of? Questions::RadioField
                xml.radio_layout question.radio_layout
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
          t = Tag.find_or_create_by(name: tag.attributes['name'])
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
            next unless caption.text
            ques.caption = caption.text
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
          
          question.each_element('layout') do |layout|
            ques.layout = layout.text
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
          
          if ques.kind_of? Questions::RadioField
            question.each_element('radio_layout') do |layout|
              ques.radio_layout = layout.text
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
  
  def is_open
    read_attribute(:is_open) && (!respond_to?(:closes_at) || closes_at.nil? || closes_at > Time.now)
  end

  def is_open=(value)
    was_open = is_open
    write_attribute(:is_open, value)
    self.closes_at = nil if value && !was_open
  end
  
  def authors
    questionnaire_permissions.includes(:person).where(:can_edit => true).to_a.map(&:person).compact
  end
  
  def self.load_extensions
    Journey::QuestionnaireExtensions.extensions.each do |ext|
      include ext
    end
  end
  self.load_extensions
  
  private
  def set_published_at
    if is_open && is_open_changed?
      self.published_at = Time.now
    end
  end
  
  def set_closed_at
    if !is_open && is_open_changed?
      self.closes_at = Time.now
    end
  end
  
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
