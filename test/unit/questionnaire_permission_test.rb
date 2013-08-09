require 'test_helper'

class QuestionnairePermissionTest < ActiveSupport::TestCase
  setup do
    @questionnaire = FactoryGirl.create :questionnaire
    @person = FactoryGirl.create :person
  end
  
  test 'by default a questionnaire permission should not allow anything' do
    perm = @questionnaire.questionnaire_permissions.create(person: @person)
    assert_equal 0, @questionnaire.questionnaire_permissions.allows_anything.count
    
    QuestionnairePermission::ACTIONS.each do |action|
      assert !perm.send("can_#{action}?")
    end
    
    assert_equal 0, EmailNotification.count
  end
  
  test 'a questionnaire permission that allows response viewing should automatically create email notifications' do
    perm = @questionnaire.questionnaire_permissions.create(person: @person, can_view_answers: true)
    assert_equal 1, EmailNotification.count
    
    n = EmailNotification.first
    assert_equal @person, n.person
    assert_equal @questionnaire, n.questionnaire
    assert n.notify_on_response_submit?
  end
  
  # TODO we need to stub out Illyan here to test inviting people
end