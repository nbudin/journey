require "test_helper"

describe EmailNotification do
  before do
    @email_notification = EmailNotification.new
  end

  it "must be valid" do
    @email_notification.valid?.must_equal true
  end
end
