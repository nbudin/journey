require 'test_helper'

class AnswerControllerTest < ActionController::TestCase
  setup do
    ActionMailer::Base.deliveries = []
    
    @questionnaire = FactoryGirl.create :questionnaire, is_open: true
    @owner = FactoryGirl.create :person
    
    @questionnaire.questionnaire_permissions.create(person: @owner, can_view_answers: true)
    assert_equal 1, @questionnaire.email_notifications.count
  end
  
  test 'starting a questionnaire' do
    get :start, id: @questionnaire.id
    
    assert_equal 1, ActionMailer::Base.deliveries.count
    assert_match /\A\[#{@questionnaire.title}\]/, ActionMailer::Base.deliveries.first.subject
  end
  
  test 'submitting a questionnaire' do
    @resp = @questionnaire.responses.create
    session["response_#{@questionnaire.id}"] = @resp.id
    
    post :save_answers, id: @questionnaire.id
    
    assert_equal 1, ActionMailer::Base.deliveries.count
    assert_match /\A\[#{@questionnaire.title}\]/, ActionMailer::Base.deliveries.first.subject
  end
end
