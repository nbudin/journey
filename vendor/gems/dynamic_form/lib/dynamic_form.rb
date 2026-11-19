# Vendored from the unmaintained dynamic_form 1.1.4 (https://github.com/joelmoss/dynamic_form, MIT License).
#
# Only the error_message_on / error_messages_for view helpers are kept.  The gem's other half redefined
# ActiveModel::Errors#full_messages to support "^"-prefixed and Proc messages; this app uses neither, and
# the redefinition broke on Ruby 3 (it passed an options hash positionally to I18n.t) and enumerated Errors as a
# hash, which Rails 7 removes.  Rails' own full_messages produces the same strings for everything used here.
require 'action_view/helpers/dynamic_form'

class ActionView::Base
  include DynamicForm
end
