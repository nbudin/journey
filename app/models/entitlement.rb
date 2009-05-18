class Entitlement < ActiveRecord::Base
  belongs_to :person

  validates_uniqueness_of :person_id

  def expired?
    expires_at < Time.new
  end

  def past_grace_period?
    expires_at < (Time.new + 30.days)
  end

  def currently_unlimited?
    if unlimited
      return (expires_at.nil? or not past_grace_period?)
    else
      return false
    end
  end

  def questionnaire_over_limit?(questionnaire)
    if currently_unlimited?
      return false
    else
      others = Questionnaire.count(:conditions => ["owner_id = ? and is_open = ? and id != ?", 
                                                   person.id, true, questionnaire.id])
      return others >= open_questionnaires
    end
  end

  def response_over_limit?(response)
    if currently_unlimited?
      return false
    else
      create_time = response.created_at || Time.new
      month_start = create_time.beginning_of_month
      month_end = create_time.end_of_month
      others = Response.count(:conditions => ["owner_id = ? and responses.create_time between ? and ? " +
                                              "and responses.id in (select response_id from answers)",
                                              person.id, month_start, month_end],
                              :joins => [:questionnaire])
      return others >= responses_per_month
    end
  end
end
