require File.dirname(__FILE__) + '/../../../../test/test_helper' # the default rails helper

# ensure that the Engines testing enhancements are loaded.
require File.join(Engines.config(:root), "engines", "lib", "testing_extensions")


# force these config values
module UserEngine
  config :role_table, "roles", :force
  config :permission_table, "permissions", :force

  config :user_role_table, "users_#{config(:role_table)}", :force
  config :permission_role_table, "#{config(:permission_table)}_#{config(:role_table)}", :force

  config :guest_role_name, "Guest", :force
  config :user_role_name, "User", :force

  config :admin_role_name, "Admin", :force
  config :admin_login, "admin", :force
  config :admin_email, "admin@your.company", :force
  config :admin_password, "testing", :force
end

# make sure we're using the right salt
module LoginEngine
  config :salt, "test-salt", :force
end

# Load the LoginEngine schema & mocks
load(File.join(Engines.get(:login).root, "db", "schema.rb"))
require File.join(Engines.get(:login).root, 'test', 'mocks', 'time')
require File.join(Engines.get(:login).root, 'test', 'mocks', 'mail')

# Load the schema - if migrations have been performed, this will be up to date.
load(File.dirname(__FILE__) + "/../db/schema.rb")

# set up the fixtures location
Test::Unit::TestCase.fixture_path = File.dirname(__FILE__)  + "/fixtures/"
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)


# Some helper methods for User Engine tests

def assert_errors
  assert_tag error_message_field
end

def assert_no_errors
  assert_no_tag error_message_field
end

def error_message_field
  {:tag => "div", :attributes => {:class => "fieldWithErrors"}}
end

# login shortcuts
def login_as_admin
  @request.session[:user] = users(:admin_user)    
end

def login(user)
  @request.session[:user] = user.nil? ? nil : users(user)
end

require 'breakpoint'
module Test::Unit::Assertions
 def my_assert_redirected_to(options = {}, message=nil)
    clean_backtrace do
      breakpoint
      assert_response(:redirect, message)

      if options.is_a?(String)
        msg = build_message(message, "expected a redirect to <?>, found one to <?>", options, @response.redirect_url)
        url_regexp = %r{^(\w+://.*?(/|$|\?))(.*)$}
        eurl, epath, url, path = [options, @response.redirect_url].collect do |url|
          u, p = (url_regexp =~ url) ? [$1, $3] : [nil, url]
          [u, (p[0..0] == '/') ? p : '/' + p]
        end.flatten

        assert_equal(eurl, url, msg) if eurl && url
        assert_equal(epath, path, msg) if epath && path 
      else
        msg = build_message(message, "response is not a redirection to all of the options supplied (redirection is <?>)",
                            @response.redirected_to || @response.redirect_url)

        assert_block(msg) do
          if options.is_a?(Symbol)
            @response.redirected_to == options
          else
            options.keys.all? do |k|
              if k == :controller then options[k] == ActionController::Routing.controller_relative_to(@response.redirected_to[k], @controller.class.controller_path)
              else options[k] == (@response.redirected_to[k].respond_to?(:to_param) ? @response.redirected_to[k].to_param : @response.redirected_to[k] unless @response.redirected_to[k].nil?)
              end
            end
          end
        end
      end
    end
  end
end  
  