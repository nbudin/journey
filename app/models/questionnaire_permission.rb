class QuestionnairePermission < ActiveRecord::Base
  belongs_to :questionnaire
  belongs_to :person
  
  ACTIONS = %w(edit view_answers edit_answers destroy change_permissions).map(&:to_sym)
  
  scope :for_person, lambda { |person| where(:person_id => person.id) }
  scope :allows_anything, lambda { where(ACTIONS.map { |a| "can_#{a} = ?" }.join(" OR "), *([true] * ACTIONS.size)) }
  ACTIONS.each do |action|
    scope "allows_#{action}", lambda { where("can_#{action}" => true) }
  end
  
  validates_uniqueness_of :questionnaire_id, :scope => :person_id
  
  def all_permissions=(granted)
    ACTIONS.each { |action| self.send("can_#{action}=", granted) }
  end
  
  def email
    person.try :email
  end
  
  def email=(email)
    if email.blank?
      self.person = nil
      return
    end
    
    logger.info "Trying to find person with email #{email}"
    self.person = Person.find_by_email(email)
    if email and self.person.nil?
      logger.info "Not found, trying Illyan invite"
      begin
        invitee = IllyanClient::Person.new(:person => { :email => email })
        invitee.save
        logger.info "Invite successful!  Got back #{invitee.inspect}"
        
        invitee_attrs = invitee.attributes["person"]
        self.person = Person.create(:email => email, :username => email, :firstname => invitee_attrs.firstname, 
          :lastname => invitee_attrs.lastname, :gender => invitee_attrs.gender, :birthdate => invitee_attrs.birthdate)
      rescue
        logger.error "Error during invite: #{$!}"
        errors.add(:base, "Error inviting new user #{email}: $!")
      end
    end
  end
end