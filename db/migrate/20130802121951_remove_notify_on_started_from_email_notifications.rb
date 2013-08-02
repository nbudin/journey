class RemoveNotifyOnStartedFromEmailNotifications < ActiveRecord::Migration
  def up
    remove_column :email_notifications, :notify_on_response_start
  end

  def down
    add_column :email_notifications, :notify_on_response_start, :boolean
  end
end
