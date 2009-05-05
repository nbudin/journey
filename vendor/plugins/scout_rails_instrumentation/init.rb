require 'scout/rails'
Scout.start! do
  ActionController::Base.class_eval do
    alias_method_chain :perform_action, :instrumentation
  end
  ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
    alias_method_chain :log, :instrumentation
  end
end
