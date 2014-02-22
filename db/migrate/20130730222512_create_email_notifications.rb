class CreateEmailNotifications < ActiveRecord::Migration
  def change
    create_table :email_notifications do |t|
      t.references :person
      t.references :questionnaire
      t.boolean :notify_on_response_start
      t.boolean :notify_on_response_submit
    end
    
    add_index :email_notifications, :questionnaire_id
    add_index :email_notifications, :person_id
    add_index :email_notifications, [:person_id, :questionnaire_id], unique: true, name: 'email_notification_person_questionnaire'
  end
end
